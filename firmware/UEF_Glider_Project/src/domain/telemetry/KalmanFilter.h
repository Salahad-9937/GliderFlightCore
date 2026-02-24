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
        explicit KalmanFilter(float q = 0.05f, float r = 0.3f)
            : _q(q), _r(r) {}

        auto update(float measurement) -> float
        {
            _p = _p + _q;
            _k = _p / (_p + _r);
            _x = _x + _k * (measurement - _x);
            _p = (1.0f - _k) * _p;
            return _x;
        }

        auto reset(float value = 0.0f) -> void
        {
            _x = value;
            _p = 1.0f;
        }

    private:
        float _q;        // Процессный шум
        float _r;        // Шум измерения
        float _x = 0.0f; // Оценка состояния
        float _p = 1.0f; // Ошибка оценки
        float _k = 0.0f; // Коэффициент усиления
    };
}

#endif