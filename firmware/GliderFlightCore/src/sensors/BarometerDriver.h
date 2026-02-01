#ifndef BAROMETER_DRIVER_H
#define BAROMETER_DRIVER_H

#include <Wire.h>
#include <Adafruit_BMP085.h>

namespace Sensors
{
    // Используем extern, чтобы компилятор знал, что sys существует где-то еще
    // (хотя при включении через Sensors.h это уже будет известно)
    struct SystemStatus;
    extern SystemStatus sys;

    Adafruit_BMP085 bmp;

    /**
     * Инициализация шины I2C и проверка наличия датчика
     */
    void initBarometer()
    {
        Wire.begin();
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

    /**
     * Чтение давления с датчика
     */
    double readPressure()
    {
        return bmp.readPressure();
    }

    /**
     * Чтение температуры с датчика
     */
    float readTemperature()
    {
        return bmp.readTemperature();
    }
}
#endif