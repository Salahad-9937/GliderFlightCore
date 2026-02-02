#ifndef SENSORS_H
#define SENSORS_H

#include <ArduinoJson.h>
#include "../config/Config.h"

// Подключаем калибровку первой, так как теперь там лежат определения типов
#include "../sensors/Calibration.h"

// Остальные драйверы и математика
#include "../sensors/BarometerDriver.h"
#include "../sensors/KalmanFilter.h"
#include "../sensors/CalibrationData.h"
#include "../sensors/AltitudeCalculator.h"

namespace Sensors
{
    // Экземпляры объектов (определены здесь, объявлены как extern в CalibrationState.h)
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