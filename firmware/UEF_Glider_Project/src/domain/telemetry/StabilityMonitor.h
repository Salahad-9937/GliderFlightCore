#ifndef DOMAIN_TELEMETRY_STABILITY_MONITOR_H
#define DOMAIN_TELEMETRY_STABILITY_MONITOR_H

#include <stdint.h>
#include <math.h>

namespace domain::telemetry
{
    /**
     * Определяет стабильность датчика.
     */
    class StabilityMonitor
    {
    public:
        struct Config
        {
            float threshold = 0.25F;
            uint16_t requiredReadings = 5;
        };

        explicit StabilityMonitor(const Config &cfg)
            : _threshold(cfg.threshold), _requiredReadings(cfg.requiredReadings) {}

        auto process(float currentAltitude) -> float
        {
            float altChange = fabsf(currentAltitude - _lastAltitude);
            _lastAltitude = currentAltitude;

            if (altChange < _threshold)
            {
                if (_stableCount < _requiredReadings + 1)
                    _stableCount++;
            }
            else
            {
                _stableCount = 0;
            }

            return isStable() ? 0.05F : 0.001F;
        }

        [[nodiscard]] auto isStable() const -> bool
        {
            return _stableCount >= _requiredReadings;
        }

        auto reset(float initialAltitude = 0.0F) -> void
        {
            _lastAltitude = initialAltitude;
            _stableCount = _requiredReadings;
        }

    private:
        float _threshold;
        uint16_t _requiredReadings;
        uint16_t _stableCount = 0;
        float _lastAltitude = 0.0F;
    };
}

#endif