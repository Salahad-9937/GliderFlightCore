#ifndef DOMAIN_TELEMETRY_CALIBRATION_PROFILE_H
#define DOMAIN_TELEMETRY_CALIBRATION_PROFILE_H

#include <stdint.h>

namespace domain::telemetry
{
    /**
     * Данные калибровки барометра для сохранения в энергонезависимую память.
     */
    struct CalibrationProfile
    {
        // Исправлено: cppcoreguidelines-use-default-member-init и readability-uppercase-literal-suffix
        float basePressure = 101325.0F; ///< Опорное давление "нуля" (Па)
        uint32_t timestamp = 0;         ///< Время проведения калибровки
        bool isValid = false;           ///< Флаг готовности данных

        // Конструктор по умолчанию использует инициализаторы членов
        CalibrationProfile() = default;
    };
}

#endif