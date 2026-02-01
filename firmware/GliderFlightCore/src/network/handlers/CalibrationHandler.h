#ifndef CALIBRATION_HANDLER_H
#define CALIBRATION_HANDLER_H

#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network
{
    /**
     * Запуск процесса калибровки барометра
     */
    void handleCalibrate()
    {
        Serial.println("[HTTP] Команда на калибровку /calibrate");
        if (!Sensors::sys.hardwareOK)
        {
            server.send(503, "text/plain", "Hardware Error: Sensor not found");
            Serial.println("[HTTP] Ошибка: датчик не найден");
            return;
        }

        // Используем полиморфный метод вместо проверки enum
        if (!Sensors::isCalibrationIdle())
        {
            server.send(409, "text/plain", "Calibration already in progress");
            return;
        }

        Sensors::startCalibration();
        server.send(202, "text/plain", "Calibration process started");
    }

    /**
     * Отмена текущего процесса (Калибровки или Обнуления)
     */
    void handleCancel()
    {
        Serial.println("[HTTP] Команда /cancel");
        Sensors::cancelCalibration();
        server.send(200, "text/plain", "Operation cancelled");
    }

    /**
     * Сохранение текущей калибровки
     */
    void handleSaveCalib()
    {
        Serial.println("[HTTP] Запрос сохранения калибровки /calibrate/save");
        if (Sensors::saveToFS())
        {
            server.send(200, "text/plain", "Calibration stored in FS");
        }
        else
        {
            server.send(500, "text/plain", "Failed to save calibration");
        }
    }
}

#endif