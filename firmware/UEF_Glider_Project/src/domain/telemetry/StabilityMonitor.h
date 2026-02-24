#ifndef DOMAIN_TELEMETRY_STABILITY_MONITOR_H
#define DOMAIN_TELEMETRY_STABILITY_MONITOR_H

#include <stdint.h>
#include <math.h>

namespace domain::telemetry
{
    /**
     * Определяет, находится ли датчик в покое.
     */
    class StabilityMonitor
    {
    public:
        /**
         * Конфигурация монитора для предотвращения перепутывания параметров.
         */
        struct Config
        {
            float threshold = 0.25F;
            uint16_t requiredReadings = 10;
        };

        explicit StabilityMonitor(const Config &cfg)
            : _threshold(cfg.threshold), _requiredReadings(cfg.requiredReadings) {}

        auto process(float currentAltitude) -> void
        {
            float diff = fabsf(currentAltitude - _lastAltitude);
            if (diff < _threshold)
            {
                if (_stableCount < _requiredReadings)
                {
                    _stableCount++;
                }
            }
            else
            {
                _stableCount = 0;
            }
            _lastAltitude = currentAltitude;
        }

        [[nodiscard]] auto isStable() const -> bool { return _stableCount >= _requiredReadings; }

        auto reset() -> void { _stableCount = 0; }

    private:
        float _threshold;
        uint16_t _requiredReadings;
        uint16_t _stableCount = 0;
        float _lastAltitude = 0.0F;
    };
}

#endif