#ifndef APPLICATION_CALIBRATION_SERVICE_H
#define APPLICATION_CALIBRATION_SERVICE_H

#include "../../core2/engine/Scheduler.h"
#include "../../core2/messaging/EventBus.h"
#include "../../drivers/sensors/Bmp180.h"
#include "../../domain/telemetry/CalibrationProfile.h"
#include "../../infrastructure/persistence/PersistenceManager.h"
#include "../events/CalibrationEvents.h"

namespace application::calibration
{
    using namespace core2;
    using namespace application::events;
    using namespace domain::telemetry;
    using namespace infrastructure::persistence;

    /**
     * @brief Сервис калибровки барометра.
     */
    class CalibrationService : public ITask
    {
    public:
        static constexpr uint32_t WARMUP_MS = 10000;
        static constexpr uint16_t FULL_SAMPLES = 2000;
        static constexpr uint16_t ZERO_SAMPLES = 500;

        explicit CalibrationService(
            drivers::Bmp180 &bmp,
            PersistenceManager &persistence,
            EventBus<> &eventBus)
            : _bmp(&bmp), _persistence(&persistence), _eventBus(&eventBus) {}

        auto startFull() -> void
        {
            if (_status != CalibrationStatus::IDLE)
            {
                return;
            }

            _status = CalibrationStatus::WARMUP;
            _startTime = millis();
            _currentProgress = 0;
            notify();
        }

        auto startZero() -> void
        {
            if (_status != CalibrationStatus::IDLE)
            {
                return;
            }

            _status = CalibrationStatus::ZEROING;
            resetAccumulator();
            notify();
        }

        auto cancel() -> void
        {
            _status = CalibrationStatus::IDLE;
            _currentProgress = 0;
            notify();
        }

        auto saveToStorage() -> Status
        {
            if (!_lastResult.isValid)
            {
                return ErrorCode::INVALID_ARGUMENT;
            }
            return _persistence->save(StorageKey::CALIBRATION, _lastResult);
        }

        void execute(uint32_t now) override
        {
            if (_status == CalibrationStatus::WARMUP)
            {
                handleWarmup(now);
            }
            else if (_status == CalibrationStatus::MEASURING)
            {
                handleSampling(FULL_SAMPLES);
            }
            else if (_status == CalibrationStatus::ZEROING)
            {
                handleSampling(ZERO_SAMPLES);
            }
        }

        [[nodiscard]] auto getStatus() const -> CalibrationStatus { return _status; }
        [[nodiscard]] auto getProgress() const -> uint8_t { return _currentProgress; }
        [[nodiscard]] auto getLastResult() const -> const CalibrationProfile & { return _lastResult; }

    private:
        void resetAccumulator()
        {
            _samplesCount = 0;
            _pressureSum = 0;
            _currentProgress = 0;
        }

        void handleWarmup(uint32_t now)
        {
            uint32_t elapsed = now - _startTime;
            _currentProgress = static_cast<uint8_t>((elapsed * 100) / WARMUP_MS);

            if (elapsed >= WARMUP_MS)
            {
                _status = CalibrationStatus::MEASURING;
                resetAccumulator();
            }
            notify(_currentProgress);
        }

        void handleSampling(uint16_t target)
        {
            auto res = _bmp->readPressure();
            if (res.isOk())
            {
                _pressureSum += res.value();
                _samplesCount++;
            }

            _currentProgress = static_cast<uint8_t>((_samplesCount * 100) / target);

            if (_samplesCount >= target)
            {
                finalize(target);
            }
            else
            {
                notify(_currentProgress);
            }
        }

        void finalize(uint16_t target)
        {
            _lastResult.basePressure = static_cast<float>(_pressureSum / target);
            _lastResult.timestamp = millis();
            _lastResult.isValid = true;

            _status = CalibrationStatus::SUCCESS;
            notify(100);
            _status = CalibrationStatus::IDLE;
        }

        void notify(uint8_t progress = 0)
        {
            _eventBus->publish(CalibrationEvent::ID, CalibrationEvent(_status, progress));
        }

        drivers::Bmp180 *_bmp = nullptr;
        PersistenceManager *_persistence = nullptr;
        EventBus<> *_eventBus = nullptr;

        CalibrationStatus _status = CalibrationStatus::IDLE;
        CalibrationProfile _lastResult;

        uint32_t _startTime = 0;
        uint16_t _samplesCount = 0;
        double _pressureSum = 0;
        uint8_t _currentProgress = 0;
    };
}

#endif