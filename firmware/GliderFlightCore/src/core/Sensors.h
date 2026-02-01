#ifndef SENSORS_H
#define SENSORS_H

#include <ArduinoJson.h>

namespace Sensors
{
    /**
     * Value Object: Статус системы.
     */
    struct SystemStatus
    {
        bool hardwareOK = false;
        bool calibrated = false;
        bool monitoring = false;
        bool logging = false;
        int flightState = 0; // 0: SETUP, 1: ARMED, 2: FLIGHT

        void serialize(JsonObject &doc) const
        {
            doc["hw_ok"] = hardwareOK;
            doc["calibrated"] = calibrated;
            doc["vcc"] = ESP.getVcc() / 1000.0;
            doc["monitoring"] = monitoring;
            doc["logging"] = logging;
            doc["flight_mode"] = flightState; // Передаем режим в приложение
        }
    };

    struct CalibrationData;
    extern SystemStatus sys;
    extern CalibrationData calData;
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