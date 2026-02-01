#ifndef SENSORS_H
#define SENSORS_H

#include <ArduinoJson.h>
#include "../config/Config.h"

namespace Sensors
{
    /**
     * Инкапсуляция логики определения стабильности.
     * Вынесено сюда для доступа из Calibration и AltitudeCalculator.
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

    struct CalibrationData;
    extern SystemStatus sys;
    extern CalibrationData calData;
    extern StabilityMonitor stability;
}

#include "../sensors/BarometerDriver.h"
#include "../sensors/KalmanFilter.h"
#include "../sensors/CalibrationData.h"
#include "../sensors/Calibration.h"
#include "../sensors/AltitudeCalculator.h"

namespace Sensors
{
    SystemStatus sys;
    CalibrationData calData;

    void serializeFullStatus(JsonObject &doc)
    {
        sys.serialize(doc);
        currentState->serialize(doc);
        doc["stored_base"] = calData.storedBasePressure;
        doc["base"] = calData.basePressure;
        telemetry.serialize(doc, sys.calibrated, sys.monitoring);
    }

    void begin()
    {
        initBarometer();
        if (sys.hardwareOK)
            loadFromFS();
    }

    void cancelCalibration() { cancel(); }

    void update()
    {
        updateCalibrationLogic();
        if (!currentState->isMeasuring())
        {
            updateAltitude();
        }
    }
}
#endif