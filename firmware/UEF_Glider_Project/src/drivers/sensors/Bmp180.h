#ifndef BMP180_DRIVER_H
#define BMP180_DRIVER_H

#include "../../core2/hal/IBarometer.h"
#include "../../core2/base/Result.h"

namespace drivers
{
    /**
     * Драйвер барометра BMP180.
     * Обертка над HAL-интерфейсом IBarometer.
     */
    class Bmp180
    {
    public:
        explicit Bmp180(core2::hal::IBarometer &hal) : _hal(&hal) {}

        /**
         * Инициализация датчика.
         */
        auto begin() -> core2::Status
        {
            return _hal->begin();
        }

        /**
         * Получить текущее давление (Па).
         */
        auto readPressure() -> core2::Result<int32_t>
        {
            return _hal->readPressure();
        }

        /**
         * Получить текущую температуру (C).
         */
        auto readTemperature() -> core2::Result<float>
        {
            return _hal->readTemperature();
        }

    private:
        core2::hal::IBarometer *_hal{nullptr};
    };
}

#endif