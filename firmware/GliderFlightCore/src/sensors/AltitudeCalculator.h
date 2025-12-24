#ifndef ALTITUDE_CALCULATOR_H
#define ALTITUDE_CALCULATOR_H

#include <math.h>
#include "BarometerDriver.h"
#include "KalmanFilter.h"
#include "Calibration.h"
#include "../config/Config.h"

namespace Sensors {
    // Состояние фильтра Калмана
    KalmanState kAlt = {0.05, 0.3, 0, 1, 0};

    // Переменные алгоритма расчета высоты
    double pressureAccumulator = 0;
    uint32_t sampleCount = 0;
    float lastRawAltitude = 0;
    int stableReadings = 0;

    // Выходные данные
    float currentAltitude = 0;
    float currentTemp = 0;
    bool isStable = false;
    double livePressure = 0;  // Последнее среднее давление из датчика

    // Управление мониторингом и логированием
    bool isMonitoring = false; // Управление опросом датчика
    bool isLogging = false;     // Управление выводом в Serial

    unsigned long logStartTime = 0;
    unsigned long last_log_time = 0;

    /**
     * Основной цикл вычислений
     */
    void update() {
        // Опрос идет если датчик ОК. 
        // Мы считаем livePressure всегда, если включен мониторинг, даже если нет калибровки.
        if (!isHardwareOK || !isMonitoring) return;

        unsigned long now = millis();
        pressureAccumulator += readPressure();
        sampleCount++;

        if (now - last_log_time >= BARO_INTERVAL) {
            last_log_time = now;

            livePressure = pressureAccumulator / (double)sampleCount;
            
            // Если еще не откалиброваны, просто сбрасываем счетчики и выходим
            if (!isCalibrated) {
                pressureAccumulator = 0;
                sampleCount = 0;
                return;
            }
            
            // Расчет высоты (стандартная формула)
            float rawAltitude = 44330.0 * (1.0 - pow(livePressure / adaptiveBaseline, 0.190295));
            
            // Адаптивная компенсация дрейфа
            float altChange = abs(rawAltitude - lastRawAltitude);
            
            if (altChange < 0.25) {
                stableReadings++;
            } else {
                stableReadings = 0;
            }
            
            float baselineAlpha = (stableReadings > STABLE_THRESHOLD) ? 0.05 : 0.001;
            adaptiveBaseline = adaptiveBaseline * (1.0 - baselineAlpha) + livePressure * baselineAlpha;
            lastRawAltitude = rawAltitude;
            
            // Фильтрация Калманом
            currentAltitude = kalmanUpdate(&kAlt, rawAltitude);
            
            // Мертвая зона
            if (abs(currentAltitude) < 0.12) {
                currentAltitude = 0.00;
            }

            currentTemp = readTemperature();
            isStable = (stableReadings > STABLE_THRESHOLD);

            // Отладочный лог в Serial
            if (isLogging) {
                float relTime = (now - logStartTime) / 1000.0;
                Serial.print("["); Serial.print(relTime, 1); Serial.print("s] ");
                Serial.print("Alt: "); Serial.print(currentAltitude, 2); Serial.print("m | ");
                Serial.print("P: "); Serial.print(livePressure, 1); Serial.print("Pa | ");
                Serial.println(isStable ? "STABLE" : "MOVING");
            }

            pressureAccumulator = 0;
            sampleCount = 0;
        }
    }
}

#endif