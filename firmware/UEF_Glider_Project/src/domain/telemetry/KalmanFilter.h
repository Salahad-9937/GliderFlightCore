#ifndef DOMAIN_TELEMETRY_KALMAN_FILTER_H
#define DOMAIN_TELEMETRY_KALMAN_FILTER_H

namespace domain::telemetry
{
    /**
     * Одномерный фильтр Калмана для сглаживания высоты.
     */
    class KalmanFilter
    {
    public:
        /**
         * Параметры фильтра.
         */
        struct Settings
        {
            float processNoise = 0.05F;    // Q
            float measurementNoise = 0.3F; // R
        };

        explicit KalmanFilter(const Settings &settings)
            : _processNoise(settings.processNoise), _measurementNoise(settings.measurementNoise) {}

        auto update(float measurement) -> float
        {
            _errorCovariance = _errorCovariance + _processNoise;
            _kalmanGain = _errorCovariance / (_errorCovariance + _measurementNoise);
            _stateEstimate = _stateEstimate + (_kalmanGain * (measurement - _stateEstimate));
            _errorCovariance = (1.0F - _kalmanGain) * _errorCovariance;
            return _stateEstimate;
        }

        auto reset(float value = 0.0F) -> void
        {
            _stateEstimate = value;
            _errorCovariance = 1.0F;
        }

    private:
        float _processNoise;           // Q
        float _measurementNoise;       // R
        float _stateEstimate = 0.0F;   // x
        float _errorCovariance = 1.0F; // p
        float _kalmanGain = 0.0F;      // k
    };
}

#endif