#ifndef SENSORS_H
#define SENSORS_H

#include "../sensors/BarometerDriver.h"
#include "../sensors/KalmanFilter.h"
#include "../sensors/Calibration.h"
#include "../sensors/AltitudeCalculator.h"

namespace Sensors {
    /**
     * Инициализация всех подсистем датчиков
     */
    void begin() {
        initBarometer();
        if (isHardwareOK) {
            loadFromFS(); // Попытка загрузки сохраненных данных
        }
    }
}

#endif