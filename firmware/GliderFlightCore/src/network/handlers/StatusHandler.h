#ifndef STATUS_HANDLER_H
#define STATUS_HANDLER_H

#include <ArduinoJson.h>
#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network {
    /**
     * Возвращает полный статус устройства
     */
    void handleStatus() {
        Serial.println("[HTTP] Запрос статуса /status");
        
        StaticJsonDocument<512> doc;
        
        // Основные флаги
        doc["hw_ok"] = Sensors::isHardwareOK;
        doc["calibrated"] = Sensors::isCalibrated;
        doc["monitoring"] = Sensors::isMonitoring;
        doc["logging"] = Sensors::isLogging;
        
        // Статус калибровки для UI
        doc["calibrating"] = (Sensors::calibState != Sensors::CALIB_IDLE);
        doc["calib_phase"] = Sensors::getCalibrationPhase(); // "stabilization", "measuring", "idle"
        doc["calib_progress"] = Sensors::getCalibrationProgress(); // 0-100
        
        doc["stored_base"] = Sensors::storedBasePressure;
        
        if (Sensors::isMonitoring) {
            doc["current_p"] = Sensors::livePressure;
        }
        
        if (Sensors::isCalibrated && Sensors::isMonitoring) {
            doc["alt"] = Sensors::currentAltitude;
            doc["temp"] = Sensors::currentTemp;
            doc["stable"] = Sensors::isStable;
            doc["base"] = Sensors::basePressure;
        }
        
        String output;
        serializeJson(doc, output);
        server.send(200, "application/json", output);
        Serial.print("[HTTP] Ответ отправлен: ");
        Serial.println(output);
    }
}

#endif