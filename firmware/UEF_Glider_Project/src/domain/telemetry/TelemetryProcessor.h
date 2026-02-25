#ifndef DOMAIN_TELEMETRY_TELEMETRY_PROCESSOR_H
#define DOMAIN_TELEMETRY_TELEMETRY_PROCESSOR_H

#include "KalmanFilter.h"
#include "AltitudeCalculator.h"
#include "StabilityMonitor.h"

namespace domain::telemetry
{
    /**
     * @brief Процессор телеметрии (Версия: Strict Baseline).
     * Адаптивная подгонка удалена для исключения дрейфа после калибровки.
     */
    class TelemetryProcessor
    {
    public:
        struct Input
        {
            float pressure;
            float temperature;
        };
        struct Output
        {
            float altitude;
            bool isStable;
        };

        explicit TelemetryProcessor(float initialBaseline)
            : _kalman(KalmanFilter::Settings{0.05F, 0.3F}),
              _stability(StabilityMonitor::Config{0.25F, 5}),
              _basePressure(initialBaseline)
        {
            _kalman.reset(0.0F);
        }

        auto process(const Input &input) -> Output
        {
            // 1. Расчет высоты относительно ЖЕСТКОЙ базы
            float rawAlt = AltitudeCalculator::calculate(input.pressure, _basePressure);

            // 2. Мониторинг стабильности (только для индикации)
            (void)_stability.process(rawAlt);

            // 3. Фильтрация Калмана
            float filtered = _kalman.update(rawAlt);

            // 4. Мертвая зона
            float finalAlt = (fabsf(filtered) < 0.12F) ? 0.0F : filtered;

            return {finalAlt, _stability.isStable()};
        }

        auto resetBaseline(float newBaseline) -> void
        {
            _basePressure = newBaseline;
            _kalman.reset(0.0F);
            _stability.reset(0.0F);
        }

    private:
        KalmanFilter _kalman;
        StabilityMonitor _stability;
        float _basePressure;
    };
}

#endif