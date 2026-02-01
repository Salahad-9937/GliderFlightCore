#ifndef PIN_CONFIG_H
#define PIN_CONFIG_H

#include <ArduinoJson.h>

namespace Config
{
    /**
     * Value Object: Конфигурация аппаратных пинов.
     * Позволяет динамически переназначать порты без перепрошивки.
     */
    struct PinConfig
    {
        int hall = 2; // Датчик Холла
        int led = 16; // Светодиод
        int sda = 4;  // I2C SDA
        int scl = 5;  // I2C SCL

        void loadDefaults()
        {
            hall = 2;
            led = 16;
            sda = 4;
            scl = 5;
        }

        String serialize() const
        {
            StaticJsonDocument<256> doc;
            doc["hall"] = hall;
            doc["led"] = led;
            doc["sda"] = sda;
            doc["scl"] = scl;
            String output;
            serializeJson(doc, output);
            return output;
        }

        bool deserialize(const String &json)
        {
            if (json == "")
                return false;
            StaticJsonDocument<256> doc;
            DeserializationError error = deserializeJson(doc, json);
            if (error)
                return false;

            hall = doc["hall"] | hall;
            led = doc["led"] | led;
            sda = doc["sda"] | sda;
            scl = doc["scl"] | scl;
            return true;
        }
    };
}
#endif