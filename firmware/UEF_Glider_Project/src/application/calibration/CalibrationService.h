#ifndef APPLICATION_CALIBRATION_SERVICE_H
#define APPLICATION_CALIBRATION_SERVICE_H

#include "../../core2/engine/Scheduler.h"
#include "../../core2/messaging/EventBus.h"
#include "../../drivers/sensors/Bmp180.h"
#include "../../domain/telemetry/Bmp180Math.h"
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
     * Сервис калибровки барометра.
     * Полностью неблокирующая реализация без использования delay().
     */
    class CalibrationService : public ITask
    {
    public:
        static constexpr uint32_t WARMUP_MS = 10000;
        static constexpr uint16_t FULL_SAMPLES = 2000;
        static constexpr uint16_t ZERO_SAMPLES = 500;
        static constexpr uint32_t CONVERSION_TIME_MS = 26; // Время замера для OSS3

        explicit CalibrationService(
            drivers::Bmp180 &bmp,
            PersistenceManager &persistence,
            EventBus<> &eventBus)
            : _bmp(&bmp), _persistence(&persistence), _eventBus(&eventBus) {}

        auto startFull() -> void
        {
            if (_status != CalibrationStatus::IDLE)
                return;
            _status = CalibrationStatus::WARMUP;
            _startTime = millis();
            notify();
        }

        auto startZero() -> void
        {
            if (_status != CalibrationStatus::IDLE)
                return;
            _status = CalibrationStatus::ZEROING;
            _samplesCount = 0;
            _pressureSum = 0;
            _isWaitingForSensor = false;
            notify();
        }

        auto cancel() -> void
        {
            _status = CalibrationStatus::IDLE;
            _isWaitingForSensor = false;
            notify();
        }

        auto saveToStorage() -> Status
        {
            if (!_lastResult.isValid)
                return ErrorCode::INVALID_ARGUMENT;
            return _persistence->save(StorageKey::CALIBRATION, _lastResult);
        }

        void execute(uint32_t now) override
        {
            switch (_status)
            {
            case CalibrationStatus::WARMUP:
                handleWarmup(now);
                break;
            case CalibrationStatus::MEASURING:
                handleSampling(now, FULL_SAMPLES);
                break;
            case CalibrationStatus::ZEROING:
                handleSampling(now, ZERO_SAMPLES);
                break;
            default:
                break;
            }
        }

        [[nodiscard]] auto getStatus() const -> CalibrationStatus { return _status; }
        [[nodiscard]] auto getLastResult() const -> const CalibrationProfile & { return _lastResult; }

    private:
        auto handleWarmup(uint32_t now) -> void
        {
            uint32_t elapsed = now - _startTime;
            if (elapsed >= WARMUP_MS)
            {
                _status = CalibrationStatus::MEASURING;
                _samplesCount = 0;
                _pressureSum = 0;
                _isWaitingForSensor = false;
            }
            notify((elapsed * 100) / WARMUP_MS);
        }

        auto handleSampling(uint32_t now, uint16_t target) -> void
        {
            if (!_isWaitingForSensor)
            {
                // Запускаем новый цикл замера
                (void)_bmp->startRawPressure(3);
                _lastSampleTime = now;
                _isWaitingForSensor = true;
                return;
            }

            // Ждем завершения преобразования датчиком
            if (now - _lastSampleTime < CONVERSION_TIME_MS)
                return;

            auto res = _bmp->readRawResult();
            if (res.isOk())
            {
                _pressureSum += res.value();
                _samplesCount++;
                _isWaitingForSensor = false; // Готовы к следующему замеру
            }

            uint8_t progress = (_samplesCount * 100) / target;
            if (_samplesCount >= target)
            {
                finalize(target);
            }
            else
            {
                notify(progress);
            }
        }

        auto finalize(uint16_t target) -> void
        {
            _lastResult.basePressure = (float)(_pressureSum / target);
            _lastResult.timestamp = millis();
            _lastResult.isValid = true;
            _status = CalibrationStatus::SUCCESS;
            notify(100);
            _status = CalibrationStatus::IDLE;
        }

        auto notify(uint8_t progress = 0) -> void
        {
            _eventBus->publish(CalibrationEvent::ID, CalibrationEvent(_status, progress));
        }

        drivers::Bmp180 *_bmp;
        PersistenceManager *_persistence;
        EventBus<> *_eventBus;

        CalibrationStatus _status = CalibrationStatus::IDLE;
        CalibrationProfile _lastResult;

        uint32_t _startTime = 0;
        uint32_t _lastSampleTime = 0;
        uint16_t _samplesCount = 0;
        double _pressureSum = 0;
        bool _isWaitingForSensor = false;
    };
}

#endif