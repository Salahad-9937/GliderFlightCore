#ifndef CONTROL_HANDLER_H
#define CONTROL_HANDLER_H

#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network {
    /**
     * Быстрое обнуление высоты (Асинхронное)
     */
    void handleZero() {
        Serial.println("[HTTP] Команда на обнуление /zero");
        if (!Sensors::isHardwareOK) {
            server.send(503, "text/plain", "Hardware Error");
            return;
        }
        
        if (Sensors::calibState != Sensors::CALIB_IDLE) {
             server.send(409, "text/plain", "Calibration/Zeroing already in progress");
             return;
        }

        Sensors::startZeroing();
        // 202 Accepted - запрос принят, выполняется в фоне
        server.send(202, "text/plain", "Zeroing started");
    }

    /**
     * Включение/выключение мониторинга барометра
     * Использование: /baro?enable=1 или /baro?enable=0
     */
    void handleBaroControl() {
        if (server.hasArg("enable")) {
            bool enable = (server.arg("enable") == "1");
            Sensors::isMonitoring = enable;
            Serial.print("[HTTP] Мониторинг барометра: ");
            Serial.println(enable ? "ВКЛ" : "ВЫКЛ");
            server.send(200, "text/plain", enable ? "Monitoring Enabled" : "Monitoring Disabled");
        } else {
            server.send(400, "text/plain", "Bad Request: missing 'enable' arg");
        }
    }

    /**
     * Управление выводом логов в Serial терминал
     * Использование: /log?enable=1 или /log?enable=0
     */
    void handleLogControl() {
        if (server.hasArg("enable")) {
            bool enable = (server.arg("enable") == "1");
            Sensors::isLogging = enable;
            if (enable) Sensors::logStartTime = millis();
            Serial.print("[HTTP] Логирование в Serial: ");
            Serial.println(enable ? "ВКЛ" : "ВЫКЛ");
            server.send(200, "text/plain", "OK");
        } else {
            server.send(400, "text/plain", "Missing 'enable' arg");
        }
    }
}

#endif