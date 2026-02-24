#ifndef CORE2_II2C_H
#define CORE2_II2C_H

#include "../base/Result.h"
#include <stdint.h>
#include <stddef.h>

namespace core2::hal
{

    /**
     * Интерфейс шины I2C (Проблема №3 - Bus Interfaces).
     * Позволяет писать драйверы датчиков независимо от Wire.h или других SDK.
     */
    class II2c
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~II2c() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        II2c() = default;
        II2c(const II2c &) = delete;
        auto operator=(const II2c &) -> II2c & = delete;
        II2c(II2c &&) = delete;
        auto operator=(II2c &&) -> II2c & = delete;

        /**
         * Запись данных ведомому устройству.
         */
        virtual auto write(uint8_t address, const uint8_t *data, size_t size) -> Status = 0;

        /**
         * Чтение данных из ведового устройства.
         */
        virtual auto read(uint8_t address, uint8_t *buffer, size_t size) -> Status = 0;
    };

} // namespace core2::hal

#endif