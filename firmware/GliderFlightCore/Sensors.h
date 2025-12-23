#ifndef SENSORS_H
#define SENSORS_H

#include <Wire.h>
#include <Adafruit_BMP085.h>
#include "Config.h"

namespace Sensors {
    Adafruit_BMP085 bmp;

    /**
     * Состояние фильтра Калмана
     */
    struct KalmanState {
        float q, r, x, p, k;
    } kAlt = {0.05, 0.3, 0, 1, 0};

    // Переменные оригинального алгоритма
    double basePressure = 0;
    double pressureAccumulator = 0;
    uint32_t sampleCount = 0;
    double adaptiveBaseline = 0;
    float lastRawAltitude = 0;
    int stableReadings = 0;

    // Глобальные флаги состояния
    float currentAltitude = 0;
    float currentTemp = 0;
    bool isStable = false;
    bool isCalibrated = false;
    bool isCalibrating = false;
    bool isHardwareOK = false;
    bool isMonitoring = false; // Управление опросом датчика
    bool isLogging = false;     // Управление выводом в Serial

    unsigned long logStartTime = 0;
    unsigned long last_log_time = 0;

    /**
     * Обновление фильтра Калмана
     */
    float kalmanUpdate(KalmanState* state, float measurement) {
        state->p = state->p + state->q;
        state->k = state->p / (state->p + state->r);
        state->x = state->x + state->k * (measurement - state->x);
        state->p = (1 - state->k) * state->p;
        return state->x;
    }

    /**
     * Полная процедура калибровки (оригинальный алгоритм)
     */
    void calibrate() {
        if (!isHardwareOK) return;
        
        isCalibrating = true;
        isCalibrated = false;
        
        Serial.println("\n[Sensors] === КОРРЕКТИРОВКА БАЗОВОГО ДАВЛЕНИЯ ===");
        Serial.println("[Sensors] Термостабилизация (10 сек)...");
        
        for (int i = 0; i < 200; i++) {
            bmp.readPressure();
            bmp.readTemperature();
            if (i % 20 == 0) Serial.print(".");
            delay(50);
        }

        Serial.println("\n[Sensors] Сбор 2000 образцов...");
        double sum = 0;
        for (int i = 0; i < 2000; i++) {
            sum += bmp.readPressure();
            if (i % 200 == 0) Serial.print(".");
            delay(5);
        }
        
        basePressure = sum / 2000.0;
        adaptiveBaseline = basePressure;
        kAlt.x = 0;
        
        isCalibrating = false;
        isCalibrated = true;
        
        Serial.print("\n[Sensors] Калибровка завершена. База: ");
        Serial.print(basePressure, 2);
        Serial.println(" Pa\n");
    }

    /**
     * Быстрая установка нуля
     */
    void zero() {
        if (!isHardwareOK) return;
        Serial.println("[Sensors] Быстрое обнуление высоты...");
        double sum = 0;
        for (int i = 0; i < 500; i++) {
            sum += bmp.readPressure();
            delay(2);
        }
        adaptiveBaseline = sum / 500.0;
        kAlt.x = 0;
        stableReadings = 0;
        isCalibrated = true;
        Serial.print("[Sensors] Новый ноль установлен: ");
        Serial.println(adaptiveBaseline, 2);
    }

    /**
     * Инициализация шины и проверка наличия датчика
     */
    void begin() {
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
     * Основной цикл вычислений
     */
    void update() {
        // Вычисления идут только если датчик исправен, откалиброван и мониторинг включен
        if (!isHardwareOK || !isCalibrated || !isMonitoring) return;

        unsigned long now = millis();
        pressureAccumulator += bmp.readPressure();
        sampleCount++;

        if (now - last_log_time >= BARO_INTERVAL) {
            last_log_time = now;

            double avgPressure = pressureAccumulator / (double)sampleCount;
            
            // Расчет высоты (стандартная формула)
            float rawAltitude = 44330.0 * (1.0 - pow(avgPressure / adaptiveBaseline, 0.190295));
            
            // Адаптивная компенсация дрейфа
            float altChange = abs(rawAltitude - lastRawAltitude);
            
            if (altChange < 0.25) {
                stableReadings++;
            } else {
                stableReadings = 0;
            }
            
            float baselineAlpha = (stableReadings > STABLE_THRESHOLD) ? 0.05 : 0.001;
            adaptiveBaseline = adaptiveBaseline * (1.0 - baselineAlpha) + avgPressure * baselineAlpha;
            lastRawAltitude = rawAltitude;
            
            // Фильтрация Калманом
            currentAltitude = kalmanUpdate(&kAlt, rawAltitude);
            
            // Мертвая зона
            if (abs(currentAltitude) < 0.12) {
                currentAltitude = 0.00;
            }

            currentTemp = bmp.readTemperature();
            isStable = (stableReadings > STABLE_THRESHOLD);

            // Отладочный лог в Serial
            if (isLogging) {
                float relTime = (now - logStartTime) / 1000.0;
                Serial.print("["); Serial.print(relTime, 1); Serial.print("s] ");
                Serial.print("Alt: "); Serial.print(currentAltitude, 2); Serial.print("m | ");
                Serial.print("T: "); Serial.print(currentTemp, 1); Serial.print("C | ");
                Serial.println(isStable ? "STABLE" : "MOVING");
            }

            pressureAccumulator = 0;
            sampleCount = 0;
        }
    }
}
#endif