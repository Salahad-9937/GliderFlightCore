#ifndef CALIBRATION_HANDLER_H
#define CALIBRATION_HANDLER_H

#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network {
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
        
        if (Sensors::calibState != Sensors::CALIB_IDLE) {
             server.send(409, "text/plain", "Calibration already in progress");
             return;
        }
        
        // Запускаем неблокирующий процесс
        Sensors::startCalibration();
        
        // 202 Accepted - запрос принят на обработку
        server.send(202, "text/plain", "Calibration process started");
        Serial.println("[HTTP] Калибровка по HTTP завершена");
    }

    /**
     * Сохранение текущей калибровки в постоянную память
     */
    void handleSaveCalib() {
        Serial.println("[HTTP] Запрос сохранения калибровки /calibrate/save");
        if (Sensors::saveToFS()) {
            server.send(200, "text/plain", "Calibration stored in FS");
        } else {
            server.send(500, "text/plain", "Failed to save calibration");
        }
    }
}

#endif