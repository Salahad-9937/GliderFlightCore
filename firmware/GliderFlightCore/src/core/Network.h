#ifndef NETWORK_H
#define NETWORK_H

#include "../network/WiFiManager.h"
#include "../network/WebServer.h"
#include "../network/handlers/StatusHandler.h"
#include "../network/handlers/CalibrationHandler.h"
#include "../network/handlers/ControlHandler.h"
#include "../network/handlers/ProgramHandler.h"
#include "../network/handlers/SystemHandler.h"

namespace Network {
    // Forward declarations
    void handleStatus();
    void handleCalibrate();
    void handleCancel();
    void handleSaveCalib();
    void handleZero();
    void handleBaroControl();
    void handleLogControl();
    void handleProgramUpload();
    void handleSystem(); // Новый обработчик
    
    /**
     * Настройка Wi-Fi и маршрутов сервера
     */
    void setup() {
        setupWiFi();
        
        Serial.println("[WebServer] Регистрация эндпоинтов...");
        server.on("/status", HTTP_GET, handleStatus);
        server.on("/system", HTTP_GET, handleSystem); // Регистрация /system
        server.on("/calibrate", HTTP_GET, handleCalibrate);
        server.on("/cancel", HTTP_GET, handleCancel);
        server.on("/calibrate/save", HTTP_GET, handleSaveCalib);
        server.on("/zero", HTTP_GET, handleZero);
        server.on("/baro", HTTP_GET, handleBaroControl);
        server.on("/log", HTTP_GET, handleLogControl);
        server.on("/program", HTTP_POST, handleProgramUpload);
        server.onNotFound(handleNotFound);
        
        startWebServer();
    }

    void loop() {
        processWebServer();
    }
}

#endif