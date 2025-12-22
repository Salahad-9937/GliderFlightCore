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
     * Отправляет текущее состояние системы и данные телеметрии в формате JSON.
     */
    void handleStatus() {
        Serial.println("[HTTP] Received request for /status");
        
        StaticJsonDocument<256> doc;
        doc["status"] = "ok";
        doc["version"] = VERSION;
        doc["device"] = "GliderFlightCore_ESP8266";
        doc["calibrated"] = Sensors::isCalibrated;
        doc["logging"] = Sensors::isLogging;
        
        // Добавление данных барометра при наличии калибровки
        if (Sensors::isCalibrated) {
            doc["alt"] = Sensors::currentAltitude;
            doc["temp"] = Sensors::currentTemp;
            doc["stable"] = Sensors::isStable;
        }
        
        String output;
        serializeJson(doc, output);
        server.send(200, "application/json", output);
        
        Serial.print("[HTTP] Sent 200 OK: ");
        Serial.println(output);
    }

    /**
     * Запускает полную процедуру калибровки барометра (термостабилизация + замеры).
     */
    void handleCalibrate() {
        Serial.println("[HTTP] Received request for /calibrate");
        Sensors::calibrate();
        server.send(200, "text/plain", "Full Calibration Complete");
        Serial.println("[HTTP] Sent 200 OK");
    }

    /**
     * Выполняет быстрое обнуление высоты (установка текущего давления как базового).
     */
    void handleZero() {
        Serial.println("[HTTP] Received request for /zero");
        Sensors::zero();
        server.send(200, "text/plain", "Zero Calibration Complete");
        Serial.println("[HTTP] Sent 200 OK");
    }

    /**
     * Активирует вывод отладочной телеметрии барометра в Serial терминал.
     */
    void handleLogStart() {
        Serial.println("[HTTP] Received request for /log/start");
        Sensors::startLogging();
        server.send(200, "text/plain", "Logging started");
        Serial.println("[HTTP] Sent 200 OK");
    }

    /**
     * Деактивирует вывод отладочной телеметрии барометра в Serial терминал.
     */
    void handleLogStop() {
        Serial.println("[HTTP] Received request for /log/stop");
        Sensors::stopLogging();
        server.send(200, "text/plain", "Logging stopped");
        Serial.println("[HTTP] Sent 200 OK");
    }

    /**
     * Обрабатывает загрузку полетной программы: валидирует JSON и сохраняет в LittleFS.
     */
    void handleProgramUpload() {
        Serial.println("[HTTP] Received POST request for /program");
        
        // Проверка наличия тела запроса
        if (!server.hasArg("plain")) {
            server.send(400, "text/plain", "Bad Request: No body");
            Serial.println("[HTTP] Sent 400: No body");
            return;
        }

        String body = server.arg("plain");
        Serial.println("[Program] Received JSON string:");
        Serial.println(body);

        // Десериализация для проверки корректности структуры JSON
        StaticJsonDocument<1024> tempDoc;
        DeserializationError error = deserializeJson(tempDoc, body);
        
        if (error) {
            Serial.print("[Program] JSON Deserialization failed: ");
            Serial.println(error.c_str());
            server.send(400, "text/plain", "Invalid JSON");
            return;
        }

        // Сохранение проверенных данных в файл
        if (Storage::saveProgram(body)) {
            server.send(200, "text/plain", "OK");
            Serial.println("[HTTP] Sent 200 OK");
        } else {
            server.send(500, "text/plain", "Internal Storage Error");
            Serial.println("[HTTP] Sent 500: FS Error");
        }
    }

    /**
     * Обработчик для всех некорректных URL.
     */
    void handleNotFound() {
        Serial.print("[HTTP] Unknown URL requested: ");
        Serial.println(server.uri());
        server.send(404, "text/plain", "Not found");
        Serial.println("[HTTP] Sent 404 Not Found");
    }

    /**
     * Настройка Wi-Fi SoftAP и регистрация всех эндпоинтов REST API.
     */
    void setup() {
        Serial.println("[WiFi] Starting Access Point...");
        if (WiFi.softAP(AP_SSID, AP_PASS)) {
            Serial.println("[WiFi] Access Point started successfully!");
            Serial.print("[INFO] SSID: ");
            Serial.println(AP_SSID);
            Serial.print("[INFO] IP Address: ");
            Serial.println(WiFi.softAPIP());
        } else {
            Serial.println("[WiFi] FAILED to start Access Point. Halting.");
            while(1) delay(100);
        }

        Serial.println("[WebServer] Configuring routes...");
        
        // Регистрация обработчиков
        server.on("/status", HTTP_GET, handleStatus);
        server.on("/calibrate", HTTP_GET, handleCalibrate);
        server.on("/zero", HTTP_GET, handleZero);
        server.on("/log/start", HTTP_GET, handleLogStart);
        server.on("/log/stop", HTTP_GET, handleLogStop);
        server.on("/program", HTTP_POST, handleProgramUpload);
        server.onNotFound(handleNotFound);
        
        server.begin();
        Serial.println("[WebServer] HTTP server started.");
    }

    /**
     * Поддержание работы веб-сервера.
     */
    void loop() {
        server.handleClient();
    }
}

#endif