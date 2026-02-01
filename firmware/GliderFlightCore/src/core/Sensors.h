#ifndef SENSORS_H
#define SENSORS_H

namespace Sensors
{
    struct SystemStatus
    {
        bool hardwareOK = false;
        bool calibrated = false;
        bool monitoring = false;
        bool logging = false;
    };
    extern SystemStatus sys;
}

#include "../sensors/BarometerDriver.h"
#include "../sensors/KalmanFilter.h"
#include "../sensors/Calibration.h"
#include "../sensors/AltitudeCalculator.h"

namespace Sensors
{
    SystemStatus sys;

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
        // Используем полиморфный метод isMeasuring() для блокировки
        if (!currentState->isMeasuring())
        {
            updateAltitude();
        }
    }
}
#endif