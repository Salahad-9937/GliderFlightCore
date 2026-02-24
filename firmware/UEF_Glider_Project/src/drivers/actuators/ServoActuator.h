#ifndef SERVO_ACTUATOR_DRIVER_H
#define SERVO_ACTUATOR_DRIVER_H

#include "../../core2/hal/IActuator.h"
#include "../../core2/base/Result.h"

namespace drivers
{
    /**
     * Драйвер сервопривода.
     * Просто пробрасывает значение на уровень HAL.
     */
    class ServoActuator
    {
    public:
        // Исправлено: добавлен explicit
        explicit ServoActuator(core2::hal::IActuator &hal) : _hal(&hal) {}

        /**
         * Установить позицию (угол или микросекунды)
         */
        auto setPosition(int16_t value) -> core2::Status
        {
            // Исправлено: обращение через указатель
            return _hal->setValue(value);
        }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members
        core2::hal::IActuator *_hal{nullptr};
    };
}

#endif