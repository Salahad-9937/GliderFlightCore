#ifndef HALL_SENSOR_DRIVER_H
#define HALL_SENSOR_DRIVER_H

#include "../../core2/hal/IGpio.h"
#include "../../core2/base/Result.h"

namespace drivers
{
    /**
     * Драйвер датчика Холла.
     * Только инициализация и чтение физического состояния.
     */
    class HallSensor
    {
    public:
        // Исправлено: добавлен спецификатор explicit
        explicit HallSensor(core2::hal::IDigitalInput &input) : _input(&input) {}

        /**
         * Проверка доступности пина (аналог проверки ID в BMP180)
         */
        auto begin() -> core2::Status
        {
            // Исправлено: обращение через указатель
            auto res = _input->read();
            return res.isOk() ? core2::Status::ok() : core2::Status::fail(core2::ErrorCode::HARDWARE_FAILURE);
        }

        /**
         * Получить сырое состояние датчика
         * @return true - поле есть (LOW), false - поля нет (HIGH)
         */
        auto readRaw() -> core2::Result<bool>
        {
            // Исправлено: обращение через указатель
            return _input->read();
        }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members
        core2::hal::IDigitalInput *_input{nullptr};
    };
}

#endif