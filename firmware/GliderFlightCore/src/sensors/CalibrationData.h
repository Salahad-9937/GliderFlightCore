#ifndef CALIBRATION_DATA_H
#define CALIBRATION_DATA_H

#include <ArduinoJson.h>

namespace Sensors
{
    /**
     * Data Mapper: Данные калибровки для хранения.
     * Отделяет логику Persistence от логики вычислений (Устранение Divergent Change).
     */
    struct CalibrationData
    {
        double basePressure = 0;
        double adaptiveBaseline = 0;
        double storedBasePressure = 0;

        String serialize() const
        {
            StaticJsonDocument<128> doc;
            doc["basePressure"] = basePressure;
            String output;
            serializeJson(doc, output);
            return output;
        }

        bool deserialize(const String &json)
        {
            if (json == "")
                return false;
            StaticJsonDocument<128> doc;
            DeserializationError error = deserializeJson(doc, json);
            if (!error)
            {
                double val = doc["basePressure"];
                if (val > 0)
                {
                    basePressure = adaptiveBaseline = storedBasePressure = val;
                    return true;
                }
            }
            return false;
        }
    };
}
#endif