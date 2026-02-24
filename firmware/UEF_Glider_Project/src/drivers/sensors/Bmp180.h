#ifndef BMP180_DRIVER_H
#define BMP180_DRIVER_H

#include "../../core2/hal/II2c.h"
#include "../../core2/base/Result.h"
#include "Bmp180Types.h" // Подключаем общие типы
#include <array>

namespace drivers
{
    class Bmp180
    {
    public:
        static constexpr uint8_t I2C_ADDR = 0x77;

        // Исправлено: explicit и замена ссылки на указатель
        explicit Bmp180(core2::hal::II2c &i2c) : _i2c(&i2c) {}

        auto begin() -> core2::Status
        {
            uint8_t reg = 0xD0;
            uint8_t id = 0;
            // Исправлено: доступ через указатель и явная передача адреса переменной
            if (!_i2c->write(I2C_ADDR, &reg, 1).isOk())
            {
                return core2::Status::fail(core2::ErrorCode::HARDWARE_FAILURE);
            }
            if (!_i2c->read(I2C_ADDR, &id, 1).isOk())
            {
                return core2::Status::fail(core2::ErrorCode::HARDWARE_FAILURE);
            }

            if (id != 0x55)
            {
                return core2::Status::fail(core2::ErrorCode::HARDWARE_FAILURE);
            }

            _isInitialized = true;
            return core2::Status::ok();
        }

        auto readCalibrationData() -> core2::Result<Bmp180Calibration>
        {
            uint8_t reg = 0xAA;
            // Исправлено: cppcoreguidelines-avoid-c-arrays
            std::array<uint8_t, 22> buffer{};
            // Исправлено: cppcoreguidelines-pro-type-member-init
            Bmp180Calibration cal{};

            if (!_i2c->write(I2C_ADDR, &reg, 1).isOk())
            {
                return core2::ErrorCode::HARDWARE_FAILURE;
            }
            // Исправлено: cppcoreguidelines-pro-bounds-array-to-pointer-decay (.data())
            if (!_i2c->read(I2C_ADDR, buffer.data(), buffer.size()).isOk())
            {
                return core2::ErrorCode::HARDWARE_FAILURE;
            }

            // NOLINTBEGIN(cppcoreguidelines-pro-bounds-constant-array-index)
            cal.ac1 = static_cast<int16_t>((buffer[0] << 8) | buffer[1]);
            cal.ac2 = static_cast<int16_t>((buffer[2] << 8) | buffer[3]);
            cal.ac3 = static_cast<int16_t>((buffer[4] << 8) | buffer[5]);
            cal.ac4 = static_cast<uint16_t>((buffer[6] << 8) | buffer[7]);
            cal.ac5 = static_cast<uint16_t>((buffer[8] << 8) | buffer[9]);
            cal.ac6 = static_cast<uint16_t>((buffer[10] << 8) | buffer[11]);
            cal.b1 = static_cast<int16_t>((buffer[12] << 8) | buffer[13]);
            cal.b2 = static_cast<int16_t>((buffer[14] << 8) | buffer[15]);
            cal.mb = static_cast<int16_t>((buffer[16] << 8) | buffer[17]);
            cal.mc = static_cast<int16_t>((buffer[18] << 8) | buffer[19]);
            cal.md = static_cast<int16_t>((buffer[20] << 8) | buffer[21]);
            // NOLINTEND(cppcoreguidelines-pro-bounds-constant-array-index)

            return cal;
        }

        auto startRawTemperature() -> core2::Status
        {
            // Исправлено: cppcoreguidelines-avoid-c-arrays
            std::array<uint8_t, 2> cmd = {{0xF4, 0x2E}};
            return _i2c->write(I2C_ADDR, cmd.data(), cmd.size());
        }

        auto startRawPressure(uint8_t oss = 0) -> core2::Status
        {
            // Исправлено: cppcoreguidelines-avoid-c-arrays
            std::array<uint8_t, 2> cmd = {{0xF4, static_cast<uint8_t>(0x34 + (oss << 6))}};
            return _i2c->write(I2C_ADDR, cmd.data(), cmd.size());
        }

        auto readRawResult() -> core2::Result<uint32_t>
        {
            uint8_t reg = 0xF6;
            // Исправлено: cppcoreguidelines-avoid-c-arrays
            std::array<uint8_t, 3> buffer{};
            if (!_i2c->write(I2C_ADDR, &reg, 1).isOk())
            {
                return core2::ErrorCode::HARDWARE_FAILURE;
            }
            if (!_i2c->read(I2C_ADDR, buffer.data(), buffer.size()).isOk())
            {
                return core2::ErrorCode::HARDWARE_FAILURE;
            }

            // NOLINTBEGIN(cppcoreguidelines-pro-bounds-constant-array-index)
            uint32_t res = (static_cast<uint32_t>(buffer[0]) << 16) | (static_cast<uint32_t>(buffer[1]) << 8) | static_cast<uint32_t>(buffer[2]);
            // NOLINTEND(cppcoreguidelines-pro-bounds-constant-array-index)
            return res >> 8;
        }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members
        core2::hal::II2c *_i2c{nullptr};
        // Исправлено: cppcoreguidelines-use-default-member-init
        bool _isInitialized{false};
    };
}

#endif