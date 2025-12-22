#ifndef SENSORS_H
#define SENSORS_H

#include <Wire.h>
#include <Adafruit_BMP085.h>
#include "Config.h"

namespace Sensors {
    Adafruit_BMP085 bmp;

    /**
     * Фильтр Калмана (Оригинальные параметры)
     */
    struct KalmanState {
        float q, r, x, p, k;
    } kAlt = {0.05, 0.3, 0, 1, 0};

    // Переменные из оригинального кода
    double basePressure = 0;
    double pressureAccumulator = 0;
    uint32_t sampleCount = 0;
    double adaptiveBaseline = 0;
    float lastRawAltitude = 0;
    int stableReadings = 0;

    // Состояние и телеметрия
    float currentAltitude = 0;
    float currentTemp = 0;
    bool isStable = false;
    bool isCalibrated = false;
    bool isLogging = false;
    unsigned long logStartTime = 0;
    unsigned long last_log_time = 0;

    /**
     * Математика фильтра Калмана
     */
    float kalmanUpdate(KalmanState* state, float measurement) {
        state->p = state->p + state->q;
        state->k = state->p / (state->p + state->r);
        state->x = state->x + state->k * (measurement - state->x);
        state->p = (1 - state->k) * state->p;
        return state->x;
    }

    /**
     * Оригинальная процедура калибровки (1:1)
     */
    void calibrate() {
        Serial.println("\n=== CALIBRATION STARTED ===");
        Serial.println("Thermal stabilization (10s)...");
        
        for (int i = 0; i < 200; i++) {
            bmp.readPressure();
            bmp.readTemperature();
            if (i % 20 == 0) Serial.print(".");
            delay(50);
        }

        Serial.println("\nCollecting 2000 samples...");
        double sum = 0;
        for (int i = 0; i < 2000; i++) {
            sum += bmp.readPressure();
            if (i % 200 == 0) Serial.print(".");
            delay(5);
        }
        
        basePressure = sum / 2000.0;
        adaptiveBaseline = basePressure;
        kAlt.x = 0;
        isCalibrated = true;
        
        Serial.print("\nBaseline: ");
        Serial.print(basePressure, 2);
        Serial.println(" Pa\n");
    }

    /**
     * Быстрое обнуление (команда 'Z' из оригинала)
     */
    void zero() {
        Serial.println("\n>>> ZERO CALIBRATION <<<");
        double sum = 0;
        for (int i = 0; i < 500; i++) {
            sum += bmp.readPressure();
            delay(2);
        }
        adaptiveBaseline = sum / 500.0;
        kAlt.x = 0;
        stableReadings = 0;
        Serial.print("New baseline: ");
        Serial.print(adaptiveBaseline, 2);
        Serial.println(" Pa\n");
    }

    void begin() {
        if (!bmp.begin(BMP085_ULTRAHIGHRES)) {
            Serial.println("Error: BMP180 not found");
            return;
        }
        Serial.println("[Sensors] BMP180 initialized and waiting for calibration.");
    }

    void startLogging() {
        if (!isCalibrated) {
            Serial.println("Error: Device not calibrated yet.");
            return;
        }
        isLogging = true;
        logStartTime = millis();
        Serial.println("Serial Logging: ON");
    }

    void stopLogging() {
        isLogging = false;
        Serial.println("Serial Logging: OFF");
    }

    /**
     * Основной цикл вычислений (Логика loop из оригинала)
     */
    void update() {
        if (!isCalibrated) return;

        unsigned long now = millis();
        pressureAccumulator += bmp.readPressure();
        sampleCount++;

        if (now - last_log_time >= BARO_INTERVAL) {
            last_log_time = now;

            double avgPressure = pressureAccumulator / (double)sampleCount;
            
            // Расчет высоты относительно адаптивной базы
            float rawAltitude = 44330.0 * (1.0 - pow(avgPressure / adaptiveBaseline, 0.190295));
            
            // === АДАПТИВНАЯ КОМПЕНСАЦИЯ ДРЕЙФА ===
            float altChange = abs(rawAltitude - lastRawAltitude);
            
            if (altChange < 0.25) {
                stableReadings++;
            } else {
                stableReadings = 0;
            }
            
            float baselineAlpha;
            if (stableReadings > STABLE_THRESHOLD) {
                baselineAlpha = 0.05; // Быстрая компенсация
            } else {
                baselineAlpha = 0.001; // Медленная компенсация
            }
            
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

            // Вывод лога в терминал
            if (isLogging) {
                float relativeTime = (now - logStartTime) / 1000.0;
                Serial.print("["); Serial.print(relativeTime, 1); Serial.print("s] ");
                Serial.print("Alt: "); Serial.print(currentAltitude, 2); Serial.print("m | ");
                Serial.print("Raw: "); Serial.print(rawAltitude, 2); Serial.print("m | ");
                Serial.print("T: "); Serial.print(currentTemp, 1); Serial.print("°C | ");
                if (isStable) {
                    Serial.print("STABLE("); Serial.print(stableReadings); Serial.println(")");
                } else {
                    Serial.println("MOVING");
                }
            }

            pressureAccumulator = 0;
            sampleCount = 0;
        }
    }
}
#endif