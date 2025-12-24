#ifndef BAROMETER_DRIVER_H
#define BAROMETER_DRIVER_H

#include <Wire.h>
#include <Adafruit_BMP085.h>

namespace Sensors {
    // Экземпляр драйвера датчика
    Adafruit_BMP085 bmp;
    
    // Флаг состояния оборудования
    bool isHardwareOK = false;

    /**
     * Инициализация шины I2C и проверка наличия датчика
     */
    void initBarometer() {
        Wire.begin(); 
        if (!bmp.begin(BMP085_ULTRAHIGHRES)) {
            isHardwareOK = false;
            Serial.println("[Sensors] ОШИБКА: Датчик BMP180 не найден на шине I2C!");
        } else {
            isHardwareOK = true;
            Serial.println("[Sensors] Датчик BMP180 успешно инициализирован.");
        }
    }

    /**
     * Чтение давления с датчика
     */
    double readPressure() {
        return bmp.readPressure();
    }

    /**
     * Чтение температуры с датчика
     */
    float readTemperature() {
        return bmp.readTemperature();
    }
}

#endif