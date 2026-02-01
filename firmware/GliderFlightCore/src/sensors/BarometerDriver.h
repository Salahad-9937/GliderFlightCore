#ifndef BAROMETER_DRIVER_H
#define BAROMETER_DRIVER_H

#include <Wire.h>
#include <Adafruit_BMP085.h>
#include "../config/Config.h"

namespace Sensors
{
    struct SystemStatus;
    extern SystemStatus sys;

    Adafruit_BMP085 bmp;

    /**
     * Инициализация шины I2C с использованием динамических пинов
     */
    void initBarometer()
    {
        // Применяем пины из конфигурации
        Serial.printf("[Sensors] Инициализация I2C (SDA:%d, SCL:%d)...\n", pins.sda, pins.scl);
        Wire.begin(pins.sda, pins.scl);

        if (!bmp.begin(BMP085_ULTRAHIGHRES))
        {
            sys.hardwareOK = false;
            Serial.println("[Sensors] ОШИБКА: Датчик BMP180 не найден на шине I2C!");
        }
        else
        {
            sys.hardwareOK = true;
            Serial.println("[Sensors] Датчик BMP180 успешно инициализирован.");
        }
    }

    double readPressure()
    {
        return bmp.readPressure();
    }

    float readTemperature()
    {
        return bmp.readTemperature();
    }
}
#endif