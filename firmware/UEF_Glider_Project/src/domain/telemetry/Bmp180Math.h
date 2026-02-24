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
        /**
         * Вспомогательная структура для передачи параметров давления.
         * Устраняет риск перепутывания параметров (bugprone-easily-swappable-parameters).
         */
        struct PressureInput
        {
            int32_t uncompensatedPressure;
            int32_t b5TemperatureParam;
        };

        static auto compensateTemperature(int32_t uncompensatedTemperature, const drivers::Bmp180Calibration &cal) -> int32_t
        {
            int32_t x1 = (uncompensatedTemperature - static_cast<int32_t>(cal.ac6)) * static_cast<int32_t>(cal.ac5) >> 15;
            int32_t x2 = (static_cast<int32_t>(cal.mc) << 11) / (x1 + cal.md);
            return x1 + x2; // Это B5 в терминах даташита
        }

        static auto compensatePressure(const PressureInput &input, const drivers::Bmp180Calibration &cal, uint8_t oss) -> uint32_t
        {
            int32_t b6 = input.b5TemperatureParam - 4000;
            int32_t x1 = (cal.b2 * (b6 * b6 >> 12)) >> 11;
            int32_t x2 = cal.ac2 * b6 >> 11;
            int32_t x3 = x1 + x2;
            int32_t b3 = (((static_cast<int32_t>(cal.ac1) * 4 + x3) << (oss + 2)) + 2) / 4;

            x1 = cal.ac3 * b6 >> 13;
            x2 = (cal.b1 * (b6 * b6 >> 12)) >> 16;
            x3 = ((x1 + x2) + 2) >> 2;
            uint32_t b4 = static_cast<uint32_t>(cal.ac4) * static_cast<uint32_t>(x3 + 32768) >> 15;
            uint32_t b7 = (static_cast<uint32_t>(input.uncompensatedPressure) - static_cast<uint32_t>(b3)) * (50000 >> oss);

            uint32_t p = (b7 < 0x80000000) ? (b7 * 2) / b4 : (b7 / b4) * 2;

            x1 = static_cast<int32_t>(p >> 8) * static_cast<int32_t>(p >> 8);
            x1 = (x1 * 3038) >> 16;
            x2 = (-7357 * static_cast<int32_t>(p)) >> 16;
            return p + static_cast<uint32_t>((x1 + x2 + 3791) >> 4);
        }
    };
}

#endif