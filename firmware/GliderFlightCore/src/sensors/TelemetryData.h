#ifndef TELEMETRY_DATA_H
#define TELEMETRY_DATA_H

#include <ArduinoJson.h>

namespace Sensors
{
    /**
     * Value Object: Данные телеметрии.
     * Сама управляет своей сериализацией (Устранение Shotgun Surgery).
     */
    struct TelemetryData
    {
        float altitude = 0;
        float temperature = 0;
        bool isStable = false;
        double pressure = 0;

        void serialize(JsonObject &doc, bool isCalibrated, bool isMonitoring) const
        {
            if (isMonitoring)
            {
                doc["current_p"] = pressure;
            }

            if (isCalibrated && isMonitoring)
            {
                doc["alt"] = altitude;
                doc["temp"] = temperature;
                doc["stable"] = isStable;
            }
        }
    };
}
#endif