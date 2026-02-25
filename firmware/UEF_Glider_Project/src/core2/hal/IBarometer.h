#ifndef CORE2_HAL_IBAROMETER_H
#define CORE2_HAL_IBAROMETER_H

#include "../base/Result.h"
#include <stdint.h>

namespace core2::hal
{
    /**
     * Структура калибровочных данных BMP180.
     * Перенесена в HAL для обеспечения работы доменной математики.
     */
    struct Bmp180Calibration
    {
        int16_t ac1, ac2, ac3;
        uint16_t ac4, ac5, ac6;
        int16_t b1, b2;
        int16_t mb, mc, md;
    };

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

        virtual auto begin() -> Status = 0;
        virtual auto readPressure() -> Result<int32_t> = 0;
        virtual auto readTemperature() -> Result<float> = 0;

        // Методы для неблокирующей работы (TelemetryService)
        virtual auto readCalibrationData() -> Result<Bmp180Calibration> = 0;
        virtual auto startRawTemperature() -> Status = 0;
        virtual auto startRawPressure(uint8_t oss) -> Status = 0;
        virtual auto readRawResult() -> Result<uint32_t> = 0;
    };
}

#endif