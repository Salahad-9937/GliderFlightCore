#ifndef SENSORS_H
#define SENSORS_H

#include "../sensors/BarometerDriver.h"
#include "../sensors/KalmanFilter.h"
#include "../sensors/Calibration.h"
#include "../sensors/AltitudeCalculator.h"

namespace Sensors
{
    /**
     * Инициализация всех подсистем датчиков
     */
    void begin()
    {
        initBarometer();
        if (isHardwareOK)
        {
            loadFromFS();
        }
    }

    /**
     * Обертка для отмены калибровки
     */
    void cancelCalibration()
    {
        cancel();
    }

    /**
     * Главный цикл обновления сенсоров
     */
    void update()
    {
        // 1. Обновление логики калибровки (машина состояний)
        updateCalibrationLogic();

        // 2. Расчет высоты (только если не заняты калибровкой)
        if (calibState != CALIB_MEASURING && calibState != CALIB_ZEROING)
        {
            updateAltitude();
        }
    }
}
#endif