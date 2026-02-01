#ifndef ALTITUDE_CALCULATOR_H
#define ALTITUDE_CALCULATOR_H

#include <math.h>
#include "BarometerDriver.h"
#include "KalmanFilter.h"
#include "Calibration.h"
#include "../config/Config.h"

namespace Sensors
{
    // Состояние фильтра Калмана
    KalmanState kAlt = {0.05, 0.3, 0, 1, 0};

    // Переменные алгоритма
    double pressureAccumulator = 0;
    uint32_t sampleCount = 0;
    float lastRawAltitude = 0;
    int stableReadings = 0;

    // Выходные данные
    float currentAltitude = 0;
    float currentTemp = 0;
    bool isStable = false;
    double livePressure = 0;

    // Управление
    bool isMonitoring = false;
    bool isLogging = false;
    unsigned long logStartTime = 0;
    unsigned long last_log_time = 0;

    // --- Вспомогательные методы (Extract Method) ---

    void updateAdaptiveBaseline(float rawAltitude)
    {
        float altChange = abs(rawAltitude - lastRawAltitude);
        if (altChange < 0.25)
        {
            stableReadings++;
        }
        else
        {
            stableReadings = 0;
        }

        float baselineAlpha = (stableReadings > STABLE_THRESHOLD) ? 0.05 : 0.001;
        adaptiveBaseline = adaptiveBaseline * (1.0 - baselineAlpha) + livePressure * baselineAlpha;
        lastRawAltitude = rawAltitude;
    }

    void processTelemetryOutput(float rawAltitude, unsigned long now)
    {
        currentAltitude = kalmanUpdate(&kAlt, rawAltitude);

        if (abs(currentAltitude) < 0.12)
        {
            currentAltitude = 0.00;
        }

        currentTemp = readTemperature();
        isStable = (stableReadings > STABLE_THRESHOLD);

        if (isLogging)
        {
            float relTime = (now - logStartTime) / 1000.0;
            Serial.print("[");
            Serial.print(relTime, 1);
            Serial.print("s] ");
            Serial.print("Alt: ");
            Serial.print(currentAltitude, 2);
            Serial.print("m | ");
            Serial.print("P: ");
            Serial.print(livePressure, 1);
            Serial.print("Pa | ");
            Serial.println(isStable ? "STABLE" : "MOVING");
        }
    }

    void performCalculations(unsigned long now)
    {
        if (sampleCount > 0)
        {
            livePressure = pressureAccumulator / (double)sampleCount;
        }

        if (!isCalibrated)
        {
            pressureAccumulator = 0;
            sampleCount = 0;
            return;
        }

        float rawAltitude = 44330.0 * (1.0 - pow(livePressure / adaptiveBaseline, 0.190295));

        updateAdaptiveBaseline(rawAltitude);
        processTelemetryOutput(rawAltitude, now);

        pressureAccumulator = 0;
        sampleCount = 0;
    }

    // --- Публичный интерфейс ---

    void updateAltitude()
    {
        if (!isHardwareOK || !isMonitoring)
            return;

        pressureAccumulator += readPressure();
        sampleCount++;

        unsigned long now = millis();
        if (now - last_log_time >= BARO_INTERVAL)
        {
            last_log_time = now;
            performCalculations(now);
        }
    }
}
#endif