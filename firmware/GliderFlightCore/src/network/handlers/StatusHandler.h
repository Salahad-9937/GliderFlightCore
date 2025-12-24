#ifndef STATUS_HANDLER_H
#define STATUS_HANDLER_H

#include <ArduinoJson.h>
#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network {
    /**
     * Возвращает полный статус устройства, включая состояние сенсоров и телеметрию
     */
    void handleStatus() {
        Serial.println("[HTTP] Запрос статуса /status");
        
        StaticJsonDocument<512> doc;
        doc["status"] = "ok";
        doc["hw_ok"] = Sensors::isHardwareOK;
        doc["calibrating"] = Sensors::isCalibrating;
        doc["calibrated"] = Sensors::isCalibrated;
        doc["monitoring"] = Sensors::isMonitoring;
        doc["logging"] = Sensors::isLogging;
        
        // Индикация наличия сохраненной калибровки в файле
        doc["stored_base"] = Sensors::storedBasePressure;
        
        // Текущее атмосферное давление в реальном времени (если мониторинг ВКЛ)
        if (Sensors::isMonitoring) {
            doc["current_p"] = Sensors::livePressure;
        }
        
        if (Sensors::isCalibrated && Sensors::isMonitoring) {
            doc["alt"] = Sensors::currentAltitude;
            doc["temp"] = Sensors::currentTemp;
            doc["stable"] = Sensors::isStable;
            doc["base"] = Sensors::basePressure; // Текущее активное базовое давление
        }
        
        String output;
        serializeJson(doc, output);
        server.send(200, "application/json", output);
        Serial.print("[HTTP] Ответ отправлен: ");
        Serial.println(output);
    }
}

#endif