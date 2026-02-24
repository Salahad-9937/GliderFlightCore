#ifndef CORE2_HARDWARE_MAP_H
#define CORE2_HARDWARE_MAP_H

#include <stdint.h>

namespace core2::hal
{
    using Pin = uint8_t;

    /**
     * Value Object: Карта физических подключений устройства.
     */
    struct HardwareMap
    {
        Pin pinHall;
        Pin pinServo;
        Pin pinLed1;
        Pin pinLed2;
        Pin pinI2cSda;
        Pin pinI2cScl;
        uint32_t baudRate;
    };
}

#endif