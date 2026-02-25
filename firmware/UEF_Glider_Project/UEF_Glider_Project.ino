/**
 * ТЕСТ ДРАЙВЕРА BMP180 С ВЫЧИСЛЕНИЕМ ВЫСОТЫ И ЗАЩИТОЙ ОТ ШУМА (UEF 2.0)
 */

#include <Arduino.h>
#include <Wire.h>
#include <math.h>
#include "src/core2/Config.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/drivers/sensors/Bmp180.h"

using namespace core2;

// 1. Платформенная реализация (HAL)
platform::Esp8266Barometer baroHal;

// 2. Драйвер (Wrapper)
drivers::Bmp180 bmp(baroHal);

// Константы для вычисления высоты
float basePressure = 0.0f;
const float ALT_FACTOR = 44330.0f;
const float ALT_EXPONENT = 0.190295f;

void setup()
{
    Serial.begin(115200);
    delay(1000);
    Serial.println("\n=== BMP180 ALTITUDE TEST (V2) ===");

    // Инициализация I2C (пины SDA/SCL из Config.h)
    Wire.begin(config::DEFAULT_HW_MAP.pinI2cSda, config::DEFAULT_HW_MAP.pinI2cScl);

    // Инициализация через драйвер
    auto status = bmp.begin();
    if (status.isOk())
    {
        Serial.println("Датчик BMP180 успешно запущен.");

        // Берем первое значение как базовое
        auto pRes = bmp.readPressure();
        if (pRes.isOk())
        {
            basePressure = (float)pRes.value();
            Serial.printf("Начальное базовое давление: %.2f Па\n", basePressure);
        }
    }
    else
    {
        Serial.printf("ОШИБКА: Датчик не найден (Код: %d)\n", (int)status.error());
        while (1)
            delay(100);
    }

    Serial.println("Команды Serial: 'z' - обнулить высоту (Zero)");
}

void loop()
{
    // Обработка команд Serial
    if (Serial.available() > 0)
    {
        char cmd = (char)Serial.read();
        if (cmd == 'z')
        {
            auto pRes = bmp.readPressure();
            if (pRes.isOk() && pRes.value() < 110000)
            { // Проверка на адекватность перед сбросом
                basePressure = (float)pRes.value();
                Serial.printf("\n[ZERO] Высота сброшена. Новая база: %.2f Па\n", basePressure);
            }
            else
            {
                Serial.println("\n[ZERO] Ошибка: невозможно обнулить (некорректные данные)");
            }
        }
    }

    auto pRes = bmp.readPressure();
    auto tRes = bmp.readTemperature();

    if (pRes.isOk() && tRes.isOk())
    {
        float currentP = (float)pRes.value();
        float temp = tRes.value();

        // Проверка на аппаратный мусор (I2C Noise)
        // Если давление > 110кПа или температура > 80C — это явно сбой контакта
        if (currentP > 110000.0f || temp > 80.0f || currentP < 10000.0f)
        {
            Serial.printf("!!! I2C ERROR: Raw P=%.0f, T=%.1f (Проверьте контакты!)\n", currentP, temp);
        }
        else
        {
            // Формула расчета высоты
            float altitude = ALT_FACTOR * (1.0f - powf(currentP / basePressure, ALT_EXPONENT));

            Serial.printf("P: %.0f Па | T: %.2f C | ALT: %.2f м\n",
                          currentP, temp, altitude);
        }
    }
    else
    {
        Serial.println("Ошибка связи с датчиком!");
    }

    delay(500);
}