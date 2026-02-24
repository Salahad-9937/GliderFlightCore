#ifndef DOMAIN_TELEMETRY_BMP180_MATH_H
#define DOMAIN_TELEMETRY_BMP180_MATH_H

#include "../../drivers/sensors/Bmp180Types.h"

namespace domain::telemetry
{
    /**
     * Реализация алгоритма компенсации согласно спецификации Bosch BMP180.
     * Вынесено в домен для обеспечения чистоты драйвера.
     */
    class Bmp180Math
    {
    public:
        static auto compensateTemperature(int32_t ut, const drivers::Bmp180Calibration &cal) -> int32_t
        {
            int32_t x1 = (ut - (int32_t)cal.ac6) * (int32_t)cal.ac5 >> 15;
            int32_t x2 = ((int32_t)cal.mc << 11) / (x1 + cal.md);
            return x1 + x2; // Это B5 в терминах даташита
        }

        static auto compensatePressure(int32_t up, int32_t b5, const drivers::Bmp180Calibration &cal, uint8_t oss) -> uint32_t
        {
            int32_t b6 = b5 - 4000;
            int32_t x1 = (cal.b2 * (b6 * b6 >> 12)) >> 11;
            int32_t x2 = cal.ac2 * b6 >> 11;
            int32_t x3 = x1 + x2;
            int32_t b3 = (((int32_t)cal.ac1 * 4 + x3) << oss + 2) / 4;

            x1 = cal.ac3 * b6 >> 13;
            x2 = (cal.b1 * (b6 * b6 >> 12)) >> 16;
            x3 = ((x1 + x2) + 2) >> 2;
            uint32_t b4 = (uint32_t)cal.ac4 * (uint32_t)(x3 + 32768) >> 15;
            uint32_t b7 = ((uint32_t)up - b3) * (50000 >> oss);

            uint32_t p = (b7 < 0x80000000) ? (b7 * 2) / b4 : (b7 / b4) * 2;

            x1 = (p >> 8) * (p >> 8);
            x1 = (x1 * 3038) >> 16;
            x2 = (-7357 * (int32_t)p) >> 16;
            return p + ((x1 + x2 + 3791) >> 4);
        }
    };
}

#endif