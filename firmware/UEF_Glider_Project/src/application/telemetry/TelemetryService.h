#ifndef APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H
#define APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H

#include "../../drivers/sensors/Bmp180.h"
#include "../../domain/telemetry/Bmp180Math.h"
#include "../../domain/telemetry/KalmanFilter.h"
#include "../../domain/telemetry/AltitudeCalculator.h"
#include "../../domain/telemetry/StabilityMonitor.h"
#include "../../core2/engine/Scheduler.h"

namespace application::telemetry
{
    using namespace domain::telemetry;

    /**
     * Сервис управления телеметрией.
     * Реализует ITask для периодического опроса датчика.
     */
    class TelemetryService : public core2::ITask
    {
    public:
        struct Data
        {
            float pressure = 0.0f;
            float temperature = 0.0f;
            float altitude = 0.0f;
            bool isStable = false;
        };

        explicit TelemetryService(drivers::Bmp180 &bmp) : _bmp(&bmp) {}

        auto begin() -> core2::Status
        {
            auto status = _bmp->begin();
            if (!status.isOk())
                return status;

            auto calRes = _bmp->readCalibrationData();
            if (!calRes.isOk())
                return core2::ErrorCode::HARDWARE_FAILURE;

            _cal = calRes.value();
            _isReady = true;
            return core2::Status::ok();
        }

        auto setBasePressure(float pa) -> void { _basePressure = pa; }

        /**
         * Выполняется планировщиком.
         */
        void execute(uint32_t now) override
        {
            if (!_isReady)
                return;

            // 1. Чтение температуры (нужна для компенсации давления)
            (void)_bmp->startRawTemperature();
            delay(5); // BMP180 требует паузу. В будущем заменим на асинхронность.
            auto utRes = _bmp->readRawResult();
            if (!utRes.isOk())
                return;

            // 2. Чтение давления
            (void)_bmp->startRawPressure(3); // Ultra High Res
            delay(26);
            auto upRes = _bmp->readRawResult();
            if (!upRes.isOk())
                return;

            // 3. Компенсация (Domain Logic)
            int32_t b5 = Bmp180Math::compensateTemperature((int32_t)utRes.value(), _cal);
            _currentData.temperature = (float)((b5 + 8) >> 4) / 10.0f;

            uint32_t pa = Bmp180Math::compensatePressure((int32_t)upRes.value(), b5, _cal, 3);
            _currentData.pressure = (float)pa;

            // 4. Высота и фильтрация
            float rawAlt = AltitudeCalculator::calculate(_currentData.pressure, _basePressure);
            _currentData.altitude = _kalman.update(rawAlt);

            // 5. Стабильность
            _stability.process(_currentData.altitude);
            _currentData.isStable = _stability.isStable();
        }

        [[nodiscard]] auto getData() const -> const Data & { return _currentData; }

    private:
        drivers::Bmp180 *_bmp;
        drivers::Bmp180Calibration _cal{};

        KalmanFilter _kalman;
        StabilityMonitor _stability;

        Data _currentData;
        float _basePressure = 101325.0f; // По умолчанию уровень моря
        bool _isReady = false;
    };
}

#endif