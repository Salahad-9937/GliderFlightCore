#ifndef APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H
#define APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H

#include <Arduino.h>
#include "../../drivers/sensors/Bmp180.h"
#include "../../domain/telemetry/KalmanFilter.h"
#include "../../domain/telemetry/AltitudeCalculator.h"
#include "../../domain/telemetry/StabilityMonitor.h"
#include "../../core2/engine/Scheduler.h"

namespace application::telemetry
{
    using namespace domain::telemetry;

    /**
     * Сервис управления телеметрией.
     * Реализует накопительное усреднение, адаптивную компенсацию дрейфа и фильтрацию Калмана.
     */
    class TelemetryService : public core2::ITask
    {
    public:
        static constexpr uint32_t CALC_INTERVAL_MS = 500; // BARO_INTERVAL из старого кода

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
              _stability(StabilityMonitor::Config{0.25F, 5}) // STABLE_THRESHOLD = 5
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
         * Установка базового давления (вызывается при старте или из калибровки).
         */
        auto setBasePressure(float pressurePa) -> void
        {
            _adaptiveBaseline = pressurePa;
            _isCalibrated = true;
            _kalman.reset(0.0F);
        }

        /**
         * Выполняется планировщиком.
         * Накапливает сырые данные и раз в 500мс проводит расчеты.
         */
        void execute(uint32_t now) override
        {
            if (!_isReady)
                return;

            // 1. Сбор данных в аккумулятор (аналог sampler.add из старого кода)
            auto pRes = _bmp->readPressure();
            if (pRes.isOk())
            {
                float p = static_cast<float>(pRes.value());
                // Жесткая фильтрация аппаратного мусора I2C
                if (p > 40000.0F && p < 115000.0F)
                {
                    _pressureAccumulator += p;
                    _sampleCount++;
                }
            }

            // 2. Цикл расчетов по интервалу (аналог performCalculations)
            if (now - _lastCalcTime >= CALC_INTERVAL_MS)
            {
                _lastCalcTime = now;
                performCalculations();
            }
        }

        [[nodiscard]] auto getData() const -> const Data & { return _currentData; }

    private:
        /**
         * Основная математическая модель (1:1 со старой прошивкой).
         */
        void performCalculations()
        {
            if (_sampleCount == 0)
                return;

            // Усреднение давления
            _currentData.pressure = _pressureAccumulator / static_cast<float>(_sampleCount);
            _pressureAccumulator = 0;
            _sampleCount = 0;

            // Чтение температуры
            auto tRes = _bmp->readTemperature();
            if (tRes.isOk())
                _currentData.temperature = tRes.value();

            if (!_isCalibrated)
            {
                // Авто-инициализация базы при первом запуске, если не загружена из Flash
                setBasePressure(_currentData.pressure);
                return;
            }

            // Расчет сырой высоты относительно АДАПТИВНОЙ базы
            float rawAlt = AltitudeCalculator::calculate(_currentData.pressure, _adaptiveBaseline);

            // Расчет коэффициента адаптации (alpha) и обновление базы (Drift Compensation)
            float alpha = _stability.process(rawAlt);
            _adaptiveBaseline = _adaptiveBaseline * (1.0F - alpha) + _currentData.pressure * alpha;

            // Фильтрация Калмана (используем rawAlt, рассчитанный на текущей базе)
            _currentData.altitude = _kalman.update(rawAlt);
            _currentData.isStable = _stability.isStable();

            // Мертвая зона (deadZone = 0.12)
            if (fabsf(_currentData.altitude) < 0.12F)
            {
                _currentData.altitude = 0.0F;
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
    };
}

#endif