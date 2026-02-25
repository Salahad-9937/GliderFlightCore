#ifndef DOMAIN_TELEMETRY_STABILITY_MONITOR_H
#define DOMAIN_TELEMETRY_STABILITY_MONITOR_H

#include <stdint.h>
#include <math.h>

namespace domain::telemetry
{
    /**
     * Определяет, находится ли датчик в покое и возвращает коэффициент адаптации.
     */
    class StabilityMonitor
    {
    public:
        struct Config
        {
            float threshold = 0.25F;       ///< Порог изменения высоты (метры)
            uint16_t requiredReadings = 5; ///< Количество чтений для подтверждения
        };

        explicit StabilityMonitor(const Config &cfg)
            : _threshold(cfg.threshold), _requiredReadings(cfg.requiredReadings) {}

        /**
         * Обработка нового значения высоты.
         * @return alpha - коэффициент фильтрации для базового давления.
         */
        auto process(float currentAltitude) -> float
        {
            float altChange = fabsf(currentAltitude - _lastAltitude);
            _lastAltitude = currentAltitude;

            // Исправлено: readability-braces-around-statements
            if (altChange < _threshold)
            {
                _stableCount++;
            }
            else
            {
                _stableCount = 0;
            }

            return isStable() ? ADAPTATION_FAST : ADAPTATION_SLOW;
        }

        [[nodiscard]] auto isStable() const -> bool
        {
            return _stableCount > _requiredReadings;
        }

        auto reset() -> void { _stableCount = 0; }

    private:
        static constexpr float ADAPTATION_FAST = 0.05F;
        static constexpr float ADAPTATION_SLOW = 0.001F;

        float _threshold;
        uint16_t _requiredReadings;
        uint16_t _stableCount = 0;
        float _lastAltitude = 0.0F;
    };
}

#endif