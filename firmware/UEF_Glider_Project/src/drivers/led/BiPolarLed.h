#ifndef CORE2_DRIVER_BIPOLAR_LED_H
#define CORE2_DRIVER_BIPOLAR_LED_H

#include "../../core2/hal/IGpio.h"
#include "../../core2/base/Result.h"
#include <stdint.h>

namespace drivers
{
    /**
     * Драйвер биполярного 2-пинового светодиода.
     * Цвет зависит от разности потенциалов между пинами.
     */
    class BiPolarLed
    {
    public:
        // Исправлено: cppcoreguidelines-use-enum-class и performance-enum-size
        enum class Color : uint8_t
        {
            OFF,
            COLOR_A,
            COLOR_B
        };

        // Исправлено: explicit и переименование параметров (readability-identifier-length)
        explicit BiPolarLed(core2::hal::IDigitalOutput &pin1, core2::hal::IDigitalOutput &pin2)
            : _pin1(&pin1), _pin2(&pin2) {}

        /**
         * Установить режим работы
         */
        auto setColor(Color color) -> core2::Status
        {
            switch (color)
            {
            case Color::COLOR_A:
                // Исправлено: доступ через указатель
                _pin1->write(true);
                return _pin2->write(false);
            case Color::COLOR_B:
                _pin1->write(false);
                return _pin2->write(true);
            case Color::OFF:
            default:
                _pin1->write(false);
                return _pin2->write(false);
            }
        }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members (ссылки заменены на указатели)
        core2::hal::IDigitalOutput *_pin1{nullptr};
        core2::hal::IDigitalOutput *_pin2{nullptr};
    };
}

#endif