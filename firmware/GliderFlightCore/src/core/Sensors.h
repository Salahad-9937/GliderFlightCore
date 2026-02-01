#ifndef SENSORS_H
#define SENSORS_H

// 1. Сначала объявляем типы данных и внешние переменные,
// которые нужны всем компонентам пространства имен.
namespace Sensors
{
    /**
     * Value Object: Глобальный статус системы.
     * Объявлен в самом начале, чтобы быть доступным всем инклюдам ниже.
     */
    struct SystemStatus
    {
        bool hardwareOK = false;
        bool calibrated = false;
        bool monitoring = false;
        bool logging = false;
    };

    // Объявляем переменную как extern, чтобы драйверы и калькуляторы её видели
    extern SystemStatus sys;
}

// 2. Теперь включаем компоненты, которые используют SystemStatus
#include "../sensors/BarometerDriver.h"
#include "../sensors/KalmanFilter.h"
#include "../sensors/Calibration.h"
#include "../sensors/AltitudeCalculator.h"

namespace Sensors
{
    // 3. Определяем экземпляр (выделяем память)
    SystemStatus sys;

    /**
     * Инициализация всех подсистем датчиков
     */
    void begin()
    {
        initBarometer();
        if (sys.hardwareOK)
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
        updateCalibrationLogic();

        // Расчет высоты (только если не заняты активной фазой калибровки)
        if (calibState != CALIB_MEASURING && calibState != CALIB_ZEROING)
        {
            updateAltitude();
        }
    }
}
#endif