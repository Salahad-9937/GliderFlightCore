#ifndef BMP180_TYPES_H
#define BMP180_TYPES_H

#include <stdint.h>

namespace drivers
{
    /**
     * Общая структура калибровочных данных BMP180.
     * Вынесена отдельно для предотвращения конфликтов при линковке Mock-версии.
     */
    struct Bmp180Calibration
    {
        int16_t ac1, ac2, ac3;
        uint16_t ac4, ac5, ac6;
        int16_t b1, b2;
        int16_t mb, mc, md;
    };
}

#endif