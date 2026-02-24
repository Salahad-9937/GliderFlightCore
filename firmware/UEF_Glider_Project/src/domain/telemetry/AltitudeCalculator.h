#ifndef DOMAIN_TELEMETRY_ALTITUDE_CALCULATOR_H
#define DOMAIN_TELEMETRY_ALTITUDE_CALCULATOR_H

#include <math.h>

namespace domain::telemetry
{
    /**
     * Физика атмосферного давления.
     */
    class AltitudeCalculator
    {
    public:
        /**
         * Расчет относительной высоты по барометрической формуле.
         * @param currentPressure Текущее давление (Па)
         * @param basePressure Давление на уровне "нуля" (Па)
         */
        static auto calculate(float currentPressure, float basePressure) -> float
        {
            if (basePressure <= 0)
                return 0.0f;
            return 44330.0f * (1.0f - powf(currentPressure / basePressure, 0.190295f));
        }
    };
}

#endif