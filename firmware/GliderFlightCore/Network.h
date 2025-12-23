#ifndef NETWORK_H
#define NETWORK_H

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>
#include "Config.h"
#include "Storage.h"
#include "Sensors.h"

ESP8266WebServer server(80);

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
        
        if (Sensors::isCalibrated && Sensors::isMonitoring) {
            doc["alt"] = Sensors::currentAltitude;
            doc["temp"] = Sensors::currentTemp;
            doc["stable"] = Sensors::isStable;
        }
        
        String output;
        serializeJson(doc, output);
        server.send(200, "application/json", output);
        Serial.print("[HTTP] Ответ отправлен: ");
        Serial.println(output);
    }

    /**
     * Запуск процесса калибровки барометра
     */
    void handleCalibrate() {
        Serial.println("[HTTP] Команда на калибровку /calibrate");
        if (!Sensors::isHardwareOK) {
            server.send(503, "text/plain", "Hardware Error: Sensor not found");
            Serial.println("[HTTP] Ошибка: датчик не найден");
            return;
        }
        
        // Ответ 202 сообщает приложению, что запрос принят и выполняется
        server.send(202, "text/plain", "Calibration process started");
        Sensors::calibrate();
        Serial.println("[HTTP] Калибровка по HTTP завершена");
    }

    /**
     * Быстрое обнуление высоты
     */
    void handleZero() {
        Serial.println("[HTTP] Команда на обнуление /zero");
        if (!Sensors::isHardwareOK) {
            server.send(503, "text/plain", "Hardware Error");
            return;
        }
        Sensors::zero();
        server.send(200, "text/plain", "Zero set");
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

    /**
     * Загрузка полетной программы
     */
    void handleProgramUpload() {
        Serial.println("[HTTP] Загрузка программы /program");
        
        if (!server.hasArg("plain")) {
            server.send(400, "text/plain", "Bad Request: No body");
            return;
        }

        String body = server.arg("plain");
        StaticJsonDocument<1024> tempDoc;
        DeserializationError error = deserializeJson(tempDoc, body);
        
        if (error) {
            server.send(400, "text/plain", "Invalid JSON");
            Serial.print("[HTTP] Ошибка парсинга программы: ");
            Serial.println(error.c_str());
            return;
        }

        if (Storage::saveProgram(body)) {
            server.send(200, "text/plain", "OK");
            Serial.println("[HTTP] Программа сохранена успешно");
        } else {
            server.send(500, "text/plain", "FS Error");
        }
    }

    void handleNotFound() {
        server.send(404, "text/plain", "Not found");
    }

    /**
     * Настройка Wi-Fi и маршрутов сервера
     */
    void setup() {
        Serial.println("[WiFi] Запуск точки доступа...");
        if (WiFi.softAP(AP_SSID, AP_PASS)) {
            Serial.print("[WiFi] IP-адрес: ");
            Serial.println(WiFi.softAPIP());
        }

        Serial.println("[WebServer] Регистрация эндпоинтов...");
        server.on("/status", HTTP_GET, handleStatus);
        server.on("/calibrate", HTTP_GET, handleCalibrate);
        server.on("/zero", HTTP_GET, handleZero);
        server.on("/baro", HTTP_GET, handleBaroControl);
        server.on("/log", HTTP_GET, handleLogControl);
        server.on("/program", HTTP_POST, handleProgramUpload);
        server.onNotFound(handleNotFound);
        
        server.begin();
        Serial.println("[WebServer] Сервер запущен.");
    }

    void loop() {
        server.handleClient();
    }
}
#endif