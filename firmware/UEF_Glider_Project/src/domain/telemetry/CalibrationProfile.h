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
        float basePressure; ///< Опорное давление "нуля" (Па)
        uint32_t timestamp; ///< Время проведения калибровки (Unix или uptime)
        bool isValid;       ///< Флаг готовности данных

        // Конструктор по умолчанию для корректной инициализации
        CalibrationProfile() : basePressure(101325.0f), timestamp(0), isValid(false) {}
    };
}

#endif