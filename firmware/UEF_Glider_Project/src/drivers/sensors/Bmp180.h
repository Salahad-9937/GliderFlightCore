#ifndef BMP180_DRIVER_H
#define BMP180_DRIVER_H

#include "../../core2/hal/IBarometer.h"
#include "../../core2/base/Result.h"

namespace drivers
{
    /**
     * Драйвер барометра BMP180.
     * Обертка над HAL-интерфейсом IBarometer.
     * Проксирует вызовы к платформенной реализации для поддержки сервисов.
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

        /**
         * Чтение калибровочных коэффициентов из HAL.
         */
        auto readCalibrationData() -> core2::Result<core2::hal::Bmp180Calibration>
        {
            return _hal->readCalibrationData();
        }

        /**
         * Запуск измерения температуры (неблокирующий).
         */
        auto startRawTemperature() -> core2::Status
        {
            return _hal->startRawTemperature();
        }

        /**
         * Запуск измерения давления (неблокирующий).
         */
        auto startRawPressure(uint8_t oss) -> core2::Status
        {
            return _hal->startRawPressure(oss);
        }

        /**
         * Чтение сырого результата из HAL.
         */
        auto readRawResult() -> core2::Result<uint32_t>
        {
            return _hal->readRawResult();
        }

    private:
        core2::hal::IBarometer *_hal{nullptr};
    };
}

#endif