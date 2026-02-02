#ifndef CALIBRATION_STATE_H
#define CALIBRATION_STATE_H

#include <ArduinoJson.h>
#include <Arduino.h>
#include "../../config/Config.h"

namespace Sensors
{
    /**
     * Инкапсуляция логики определения стабильности.
     */
    class StabilityMonitor
    {
    private:
        float _lastRawAltitude = 0;
        int _stableReadings = 0;
        const float _threshold;

    public:
        StabilityMonitor(float threshold) : _threshold(threshold) {}

        float process(float rawAltitude)
        {
            float altChange = abs(rawAltitude - _lastRawAltitude);
            _stableReadings = (altChange < _threshold) ? _stableReadings + 1 : 0;
            _lastRawAltitude = rawAltitude;

            return (_stableReadings > STABLE_THRESHOLD) ? 0.05 : 0.001;
        }

        bool isStable() const { return _stableReadings > STABLE_THRESHOLD; }
        void reset() { _stableReadings = 0; }
    };

    /**
     * Value Object: Статус системы.
     */
    struct SystemStatus
    {
        bool hardwareOK = false;
        bool calibrated = false;
        bool monitoring = false;
        bool logging = false;
        Config::FlightState flightState = Config::STATE_SETUP;

        void serialize(JsonObject &doc) const
        {
            doc["hw_ok"] = hardwareOK;
            doc["calibrated"] = calibrated;
            doc["vcc"] = ESP.getVcc() / 1000.0;
            doc["monitoring"] = monitoring;
            doc["logging"] = logging;
            doc["flight_mode"] = (int)flightState;
        }
    };

    /**
     * Базовый интерфейс состояний калибровки.
     */
    class CalibrationState
    {
    public:
        virtual void update(unsigned long now) = 0;
        virtual int getProgress() = 0;
        virtual String getPhaseName() = 0;
        virtual void serialize(JsonObject &doc) = 0;
        virtual void onEnter() {}
        virtual bool isMeasuring() { return true; }
        virtual bool isIdle() { return false; }
    };

    // Опережающее объявление данных калибровки (они в другом файле)
    struct CalibrationData;
    struct KalmanState;

    // Ссылки на глобальные объекты
    extern SystemStatus sys;
    extern CalibrationData calData;
    extern KalmanState kAlt;
    extern StabilityMonitor stability;

    // Опережающие объявления функций переходов
    void transitionToIdle();
    void transitionToMeasuring();

    // Глобальные указатели на объекты состояний
    class IdleState;
    class WarmupState;
    class MeasuringState;
    class ZeroingState;
    extern IdleState idleStateObj;
    extern WarmupState warmupStateObj;
    extern MeasuringState measuringStateObj;
    extern ZeroingState zeroingStateObj;
}

#endif