#ifndef CORE2_CONFIG_H
#define CORE2_CONFIG_H

#include <stddef.h>
#include "hal/HardwareMap.h"

namespace core2::config
{
    static constexpr size_t LOG_BUFFER_SIZE = 1024;
    static constexpr size_t MAX_TASKS = 8;
    static constexpr size_t MAX_LISTENERS = 8;
    static constexpr size_t MAX_EVENT_RECURSION = 4;

    /**
     * Дефолтная конфигурация железа для ESP8266.
     */
    const hal::HardwareMap DEFAULT_HW_MAP = {
        2,     // pinHall    (GPIO2 / D4)
        14,    // pinServo   (GPIO14 / D5)
        16,    // pinLed1    (GPIO16 / D0)
        0,     // pinLed2    (GPIO0 / D3)
        4,     // pinI2cSda  (GPIO4 / D2)
        5,     // pinI2cScl  (GPIO5 / D1)
        115200 // baudRate
    };
}

#endif