#ifndef DOMAIN_TELEMETRY_TELEMETRY_PROCESSOR_H
#define DOMAIN_TELEMETRY_TELEMETRY_PROCESSOR_H

#include "KalmanFilter.h"
#include "AltitudeCalculator.h"
#include "StabilityMonitor.h"

namespace domain::telemetry
{
    /**
     * @brief Чистая доменная модель для обработки данных телеметрии.
     * Реализует SRP: только математика и фильтрация, без привязки к железу.
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
            float adaptiveBaseline;
        };

        explicit TelemetryProcessor(float initialBaseline)
            : _kalman(KalmanFilter::Settings{0.05F, 0.3F}),
              _stability(StabilityMonitor::Config{0.25F, 5}),
              _adaptiveBaseline(initialBaseline)
        {
            _kalman.reset(0.0F);
        }

        /**
         * Основной конвейер обработки данных.
         */
        auto process(const Input &in) -> Output
        {
            // 1. Расчет относительной высоты
            float rawAlt = AltitudeCalculator::calculate(in.pressure, _adaptiveBaseline);

            // 2. Адаптация базового давления (компенсация дрейфа)
            float alpha = _stability.process(rawAlt);
            _adaptiveBaseline = _adaptiveBaseline * (1.0F - alpha) + in.pressure * alpha;

            // 3. Фильтрация Калмана
            float filtered = _kalman.update(rawAlt);

            // 4. Применение мертвой зоны
            float finalAlt = (fabsf(filtered) < 0.12F) ? 0.0F : filtered;

            return {finalAlt, _stability.isStable(), _adaptiveBaseline};
        }

        auto resetBaseline(float newBaseline) -> void
        {
            _adaptiveBaseline = newBaseline;
            _kalman.reset(0.0F);
            _stability.reset();
        }

    private:
        KalmanFilter _kalman;
        StabilityMonitor _stability;
        float _adaptiveBaseline;
    };
}

#endif