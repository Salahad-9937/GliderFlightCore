#ifndef APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H
#define APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H

#include <Arduino.h>
#include "../../drivers/sensors/Bmp180.h"
#include "../../domain/telemetry/KalmanFilter.h"
#include "../../domain/telemetry/AltitudeCalculator.h"
#include "../../domain/telemetry/StabilityMonitor.h"
#include "../../core2/engine/Scheduler.h"
#include "../../core2/base/Registry.h"

namespace application::telemetry
{
    using namespace domain::telemetry;

    /**
     * @brief Сервис управления телеметрией.
     */
    class TelemetryService : public core2::ITask
    {
    public:
        static constexpr uint32_t CALC_INTERVAL_MS = 500;

        struct Data
        {
            float pressure = 0.0F;
            float temperature = 0.0F;
            float altitude = 0.0F;
            bool isStable = false;
        };

        explicit TelemetryService(drivers::Bmp180 &bmp)
            : _bmp(&bmp),
              _kalman(KalmanFilter::Settings{0.05F, 0.3F}),
              _stability(StabilityMonitor::Config{0.25F, 5})
        {
        }

        auto begin() -> core2::Status
        {
            auto status = _bmp->begin();
            if (!status.isOk())
                return status;
            _isReady = true;
            return core2::Status::ok();
        }

        auto setBasePressure(float pressurePa) -> void
        {
            _adaptiveBaseline = pressurePa;
            _isCalibrated = true;
            _kalman.reset(0.0F);
        }

        void setMonitoring(bool enable) { _isMonitoring = enable; }
        bool isMonitoring() const { return _isMonitoring; }

        void setLogging(bool enable) { _isLogging = enable; }
        bool isLogging() const { return _isLogging; }

        void execute(uint32_t now) override
        {
            if (!_isReady || !_isMonitoring)
                return;

            accumulatePressure();

            if (now - _lastCalcTime >= CALC_INTERVAL_MS)
            {
                _lastCalcTime = now;
                performCalculations();
            }
        }

        [[nodiscard]] auto getData() const -> const Data & { return _currentData; }

    private:
        /**
         * Сбор и первичная фильтрация данных.
         */
        void accumulatePressure()
        {
            auto pRes = _bmp->readPressure();
            if (pRes.isOk())
            {
                float p = static_cast<float>(pRes.value());
                if (isValidPressure(p))
                {
                    _pressureAccumulator += p;
                    _sampleCount++;
                }
            }
        }

        /**
         * Проверка физической достоверности давления.
         */
        bool isValidPressure(float p) const
        {
            return (p > 40000.0F && p < 115000.0F);
        }

        /**
         * Основной цикл расчетов.
         */
        void performCalculations()
        {
            if (_sampleCount == 0)
                return;

            updateAveragePressure();
            updateTemperature();

            if (!_isCalibrated)
            {
                setBasePressure(_currentData.pressure);
                return;
            }

            processAltitude();

            if (_isLogging)
                logDiagnostics();
        }

        void updateAveragePressure()
        {
            _currentData.pressure = _pressureAccumulator / static_cast<float>(_sampleCount);
            _pressureAccumulator = 0;
            _sampleCount = 0;
        }

        void updateTemperature()
        {
            auto tRes = _bmp->readTemperature();
            if (tRes.isOk())
                _currentData.temperature = tRes.value();
        }

        void processAltitude()
        {
            float rawAlt = AltitudeCalculator::calculate(_currentData.pressure, _adaptiveBaseline);

            // Адаптация базового давления (компенсация дрейфа)
            float alpha = _stability.process(rawAlt);
            _adaptiveBaseline = _adaptiveBaseline * (1.0F - alpha) + _currentData.pressure * alpha;

            // Фильтрация и мертвая зона
            float filtered = _kalman.update(rawAlt);
            _currentData.altitude = (fabsf(filtered) < 0.12F) ? 0.0F : filtered;
            _currentData.isStable = _stability.isStable();
        }

        void logDiagnostics() const
        {
            char buf[64];
            snprintf(buf, sizeof(buf), "TELE: Alt: %.2f, P: %.0f\n", _currentData.altitude, _currentData.pressure);
            core2::Registry::getLogger().info(buf);
        }

        drivers::Bmp180 *_bmp;
        KalmanFilter _kalman;
        StabilityMonitor _stability;

        Data _currentData;
        float _adaptiveBaseline = 101325.0F;
        float _pressureAccumulator = 0.0F;
        uint16_t _sampleCount = 0;
        uint32_t _lastCalcTime = 0;
        bool _isReady = false;
        bool _isCalibrated = false;
        bool _isMonitoring = false;
        bool _isLogging = false;
    };
}

#endif