#ifndef CORE2_HAL_IBAROMETER_H
#define CORE2_HAL_IBAROMETER_H

#include "../base/Result.h"
#include <stdint.h>

namespace core2::hal
{
    /**
     * Интерфейс барометрического датчика.
     */
    class IBarometer
    {
    public:
        virtual ~IBarometer() = default;

        IBarometer() = default;
        IBarometer(const IBarometer &) = delete;
        auto operator=(const IBarometer &) -> IBarometer & = delete;
        IBarometer(IBarometer &&) = delete;
        auto operator=(IBarometer &&) -> IBarometer & = delete;

        /**
         * Инициализация датчика.
         */
        virtual auto begin() -> Status = 0;

        /**
         * Чтение компенсированного давления в Паскалях.
         */
        virtual auto readPressure() -> Result<int32_t> = 0;

        /**
         * Чтение температуры в градусах Цельсия.
         */
        virtual auto readTemperature() -> Result<float> = 0;
    };
}

#endif