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
        
        // Ответ 202 сообщает приложению, что запрос принят и выполняется
        server.send(202, "text/plain", "Calibration process started");
        Sensors::calibrate();
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