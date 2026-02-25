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
     * Реализует накопительное усреднение, адаптивную компенсацию дрейфа и фильтрацию Калмана.
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

        /**
         * Установка базового давления.
         */
        auto setBasePressure(float pressurePa) -> void
        {
            _adaptiveBaseline = pressurePa;
            _isCalibrated = true;
            _kalman.reset(0.0F);
        }

        // Управление состоянием опроса
        void setMonitoring(bool enable) { _isMonitoring = enable; }
        bool isMonitoring() const { return _isMonitoring; }

        void setLogging(bool enable) { _isLogging = enable; }
        bool isLogging() const { return _isLogging; }

        /**
         * Выполняется планировщиком.
         */
        void execute(uint32_t now) override
        {
            if (!_isReady || !_isMonitoring)
                return;

            auto pRes = _bmp->readPressure();
            if (pRes.isOk())
            {
                float p = static_cast<float>(pRes.value());
                // Фильтрация аппаратных выбросов
                if (p > 40000.0F && p < 115000.0F)
                {
                    _pressureAccumulator += p;
                    _sampleCount++;
                }
            }

            if (now - _lastCalcTime >= CALC_INTERVAL_MS)
            {
                _lastCalcTime = now;
                performCalculations();
            }
        }

        [[nodiscard]] auto getData() const -> const Data & { return _currentData; }

    private:
        /**
         * Основная математическая модель.
         */
        void performCalculations()
        {
            if (_sampleCount == 0)
                return;

            // 1. Усреднение накопленного давления
            _currentData.pressure = _pressureAccumulator / static_cast<float>(_sampleCount);
            _pressureAccumulator = 0;
            _sampleCount = 0;

            // 2. Чтение температуры
            auto tRes = _bmp->readTemperature();
            if (tRes.isOk())
                _currentData.temperature = tRes.value();

            if (!_isCalibrated)
            {
                setBasePressure(_currentData.pressure);
                return;
            }

            // 3. Расчет высоты и компенсация дрейфа
            float rawAlt = AltitudeCalculator::calculate(_currentData.pressure, _adaptiveBaseline);
            float alpha = _stability.process(rawAlt);
            _adaptiveBaseline = _adaptiveBaseline * (1.0F - alpha) + _currentData.pressure * alpha;

            // 4. Фильтрация Калмана
            _currentData.altitude = _kalman.update(rawAlt);
            _currentData.isStable = _stability.isStable();

            // 5. Мертвая зона
            if (fabsf(_currentData.altitude) < 0.12F)
                _currentData.altitude = 0.0F;

            // 6. Диагностический вывод
            if (_isLogging)
            {
                char buf[64];
                snprintf(buf, sizeof(buf), "TELE: Alt: %.2f, P: %.0f\n", _currentData.altitude, _currentData.pressure);
                core2::Registry::getLogger().info(buf);
            }
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