#ifndef DOMAIN_TELEMETRY_STABILITY_MONITOR_H
#define DOMAIN_TELEMETRY_STABILITY_MONITOR_H

#include <stdint.h>
#include <math.h>

namespace domain::telemetry
{
    /**
     * Определяет, находится ли датчик в покое и возвращает коэффициент адаптации.
     * Полностью соответствует логике STABLE_THRESHOLD из старой прошивки.
     */
    class StabilityMonitor
    {
    public:
        struct Config
        {
            float threshold = 0.25F;       ///< Порог изменения высоты (метры)
            uint16_t requiredReadings = 5; ///< Количество чтений для подтверждения (STABLE_THRESHOLD)
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

            // Логика 1:1 из старой прошивки
            _stableCount = (altChange < _threshold) ? _stableCount + 1 : 0;
            _lastAltitude = currentAltitude;

            // Если стабилен (> 5 чтений) -> быстрая адаптация (0.05), иначе почти замерзает (0.001)
            return (_stableCount > _requiredReadings) ? 0.05F : 0.001F;
        }

        [[nodiscard]] auto isStable() const -> bool { return _stableCount > _requiredReadings; }

        auto reset() -> void { _stableCount = 0; }

    private:
        float _threshold;
        uint16_t _requiredReadings;
        uint16_t _stableCount = 0;
        float _lastAltitude = 0.0F;
    };
}

#endif