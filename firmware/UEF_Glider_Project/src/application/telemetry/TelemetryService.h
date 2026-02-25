#ifndef APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H
#define APPLICATION_TELEMETRY_TELEMETRY_SERVICE_H

#include "../../drivers/sensors/Bmp180.h"
#include "../../domain/telemetry/TelemetryProcessor.h"
#include "../../core2/engine/Scheduler.h"
#include "../../core2/base/Registry.h"

namespace application::telemetry
{
    /**
     * @brief Сервис телеметрии.
     * Отвечает за сбор данных (I/O) и координацию вычислений.
     */
    class TelemetryService : public core2::ITask
    {
    public:
        static constexpr uint32_t CALC_INTERVAL_MS = 500;

        struct Data
        {
            float pressure = 0.0F;
            float temperature = 0.0F;
            float altitude = 0.0F;
            bool isStable = false;
        };

        explicit TelemetryService(drivers::Bmp180 &bmp)
            : _bmp(&bmp), _processor(101325.0F) {}

        auto begin() -> core2::Status
        {
            auto status = _bmp->begin();
            if (status.isOk())
                _isReady = true;
            return status;
        }

        auto setBasePressure(float pressurePa) -> void
        {
            _processor.resetBaseline(pressurePa);
            _isCalibrated = true;
        }

        void setMonitoring(bool enable) { _isMonitoring = enable; }
        bool isMonitoring() const { return _isMonitoring; }
        void setLogging(bool enable) { _isLogging = enable; }
        bool isLogging() const { return _isLogging; }

        void execute(uint32_t now) override
        {
            if (!_isReady || !_isMonitoring)
                return;

            accumulateSamples();

            if (now - _lastCalcTime >= CALC_INTERVAL_MS)
            {
                _lastCalcTime = now;
                performUpdate();
            }
        }

        [[nodiscard]] auto getData() const -> const Data & { return _currentData; }

    private:
        void accumulateSamples()
        {
            auto pRes = _bmp->readPressure();
            if (pRes.isOk())
            {
                float p = static_cast<float>(pRes.value());
                if (p > 40000.0F && p < 115000.0F)
                {
                    _pressureAccumulator += p;
                    _sampleCount++;
                }
            }
        }

        void performUpdate()
        {
            if (_sampleCount == 0)
                return;

            // Подготовка входных данных
            float avgP = _pressureAccumulator / static_cast<float>(_sampleCount);
            _pressureAccumulator = 0;
            _sampleCount = 0;

            auto tRes = _bmp->readTemperature();
            float temp = tRes.isOk() ? tRes.value() : _currentData.temperature;

            // Делегирование расчетов процессору (SRP)
            domain::telemetry::TelemetryProcessor::Input in{avgP, temp};
            auto out = _processor.process(in);

            // Обновление состояния
            _currentData.pressure = avgP;
            _currentData.temperature = temp;
            _currentData.altitude = out.altitude;
            _currentData.isStable = out.isStable;

            if (_isLogging)
                log();
        }

        void log() const
        {
            char buf[64];
            snprintf(buf, sizeof(buf), "TELE: Alt: %.2f, P: %.0f\n", _currentData.altitude, _currentData.pressure);
            core2::Registry::getLogger().info(buf);
        }

        drivers::Bmp180 *_bmp;
        domain::telemetry::TelemetryProcessor _processor;
        Data _currentData;
        float _pressureAccumulator = 0.0F;
        uint16_t _sampleCount = 0;
        uint32_t _lastCalcTime = 0;
        bool _isReady = false;
        bool _isCalibrated = false;
        bool _isMonitoring = false;
        bool _isLogging = false;
    };
}

#endif