#ifndef SENSORS_H
#define SENSORS_H

#include <ArduinoJson.h>

namespace Sensors
{
    /**
     * Value Object: Статус системы.
     * Управляет сериализацией базовых флагов состояния.
     */
    struct SystemStatus
    {
        bool hardwareOK = false;
        bool calibrated = false;
        bool monitoring = false;
        bool logging = false;

        void serialize(JsonObject &doc) const
        {
            doc["hw_ok"] = hardwareOK;
            doc["calibrated"] = calibrated; // ВОССТАНОВЛЕНО: Ключ для мобильного приложения
            doc["vcc"] = ESP.getVcc() / 1000.0;
            doc["monitoring"] = monitoring;
            doc["logging"] = logging;
        }
    };

    // Предварительные объявления
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

    /**
     * Фасад для сборки полного статуса.
     * Собирает данные из всех подсистем в один JSON объект.
     */
    void serializeFullStatus(JsonObject &doc)
    {
        // 1. Базовые флаги (hw_ok, calibrated, vcc, monitoring, logging)
        sys.serialize(doc);

        // 2. Статус процесса калибровки (calibrating, calib_phase, calib_progress)
        currentState->serialize(doc);

        // 3. Данные о базовом давлении
        doc["stored_base"] = calData.storedBasePressure;
        doc["base"] = calData.basePressure;

        // 4. Телеметрия (alt, temp, stable, current_p)
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