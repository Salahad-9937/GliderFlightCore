#ifndef APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H
#define APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H

#include <Arduino.h>
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
     * Реализует ITask для периодического опроса датчика без блокировки цикла.
     */
    class TelemetryService : public core2::ITask
    {
    public:
        /**
         * Состояния внутренней машины опроса датчика.
         */
        enum class SensorState : uint8_t
        {
            IDLE,
            START_TEMP,
            WAIT_TEMP,
            START_PRESS,
            WAIT_PRESS
        };

        struct Data
        {
            float pressure = 0.0F;
            float temperature = 0.0F;
            float altitude = 0.0F;
            bool isStable = false;
        };

        explicit TelemetryService(drivers::Bmp180 &bmp)
            : _bmp(&bmp),
              _kalman(KalmanFilter::Settings{0.05F, 0.3F}),
              _stability(StabilityMonitor::Config{0.25F, 10})
        {
        }

        auto begin() -> core2::Status
        {
            auto status = _bmp->begin();
            if (!status.isOk())
            {
                return status;
            }

            auto calRes = _bmp->readCalibrationData();
            if (!calRes.isOk())
            {
                return core2::ErrorCode::HARDWARE_FAILURE;
            }

            _cal = calRes.value();
            _isReady = true;
            return core2::Status::ok();
        }

        auto setBasePressure(float pressurePa) -> void
        {
            _basePressure = pressurePa;
        }

        /**
         * Выполняется планировщиком.
         * Реализует неблокирующий цикл: Запрос -> Ожидание -> Чтение.
         */
        void execute(uint32_t now) override
        {
            if (!_isReady)
            {
                return;
            }

            switch (_sensorState)
            {
            case SensorState::IDLE:
                _sensorState = SensorState::START_TEMP;
                // fallthrough
            case SensorState::START_TEMP:
                if (_bmp->startRawTemperature().isOk())
                {
                    _lastStepTime = now;
                    _sensorState = SensorState::WAIT_TEMP;
                }
                break;

            case SensorState::WAIT_TEMP:
                if ((now - _lastStepTime) >= 5)
                {
                    auto utRes = _bmp->readRawResult();
                    if (utRes.isOk())
                    {
                        _uncompensatedTemp = static_cast<int32_t>(utRes.value());
                        _sensorState = SensorState::START_PRESS;
                    }
                    else
                    {
                        _sensorState = SensorState::START_TEMP;
                    }
                }
                break;

            case SensorState::START_PRESS:
                if (_bmp->startRawPressure(3).isOk())
                {
                    _lastStepTime = now;
                    _sensorState = SensorState::WAIT_PRESS;
                }
                break;

            case SensorState::WAIT_PRESS:
                if ((now - _lastStepTime) >= 26)
                {
                    auto upRes = _bmp->readRawResult();
                    if (upRes.isOk())
                    {
                        processData(static_cast<int32_t>(upRes.value()));
                        _sensorState = SensorState::IDLE;
                    }
                    else
                    {
                        _sensorState = SensorState::START_PRESS;
                    }
                }
                break;
            }
        }

        [[nodiscard]] auto getData() const -> const Data &
        {
            return _currentData;
        }

    private:
        auto processData(int32_t uncompensatedPressure) -> void
        {
            // 1. Компенсация температуры
            int32_t b5 = Bmp180Math::compensateTemperature(_uncompensatedTemp, _cal);
            _currentData.temperature = static_cast<float>((b5 + 8) >> 4) / 10.0F;

            // 2. Компенсация давления
            Bmp180Math::PressureInput input{uncompensatedPressure, b5};
            uint32_t pa = Bmp180Math::compensatePressure(input, _cal, 3);
            _currentData.pressure = static_cast<float>(pa);

            // 3. Высота и фильтрация
            float rawAlt = AltitudeCalculator::calculate(_currentData.pressure, _basePressure);
            _currentData.altitude = _kalman.update(rawAlt);

            // 4. Стабильность
            _stability.process(_currentData.altitude);
            _currentData.isStable = _stability.isStable();
        }

        drivers::Bmp180 *_bmp;
        drivers::Bmp180Calibration _cal{};

        KalmanFilter _kalman;
        StabilityMonitor _stability;

        Data _currentData;
        float _basePressure = 101325.0F;
        bool _isReady = false;

        SensorState _sensorState = SensorState::IDLE;
        uint32_t _lastStepTime = 0;
        int32_t _uncompensatedTemp = 0;
    };
}

#endif