#ifndef ALTITUDE_CALCULATOR_H
#define ALTITUDE_CALCULATOR_H

#include <math.h>
#include "BarometerDriver.h"
#include "KalmanFilter.h"
#include "Calibration.h"
#include "../config/Config.h"

namespace Sensors
{
    /**
     * Value Object: Конфигурация алгоритма (устранение Magic Numbers)
     */
    struct AltimeterConfig
    {
        const float seaLevelPressure = 101325.0;
        const float altFactor = 44330.0;
        const float altExponent = 0.190295;
        const float stabilityThreshold = 0.25;
        const float deadZone = 0.12;
    };

    /**
     * Value Object: Данные телеметрии (устранение Primitive Obsession)
     */
    struct TelemetryData
    {
        float altitude = 0;
        float temperature = 0;
        bool isStable = false;
        double pressure = 0;
    };

    // Состояние
    const AltimeterConfig cfg;
    TelemetryData telemetry;
    KalmanState kAlt = {0.05, 0.3, 0, 1, 0};

    double pressureAccumulator = 0;
    uint32_t sampleCount = 0;
    float lastRawAltitude = 0;
    int stableReadings = 0;

    // Управление
    bool isMonitoring = false;
    bool isLogging = false;
    unsigned long logStartTime = 0;
    unsigned long last_log_time = 0;

    // --- Вспомогательные методы (Extract Method) ---

    void updateAdaptiveBaseline(float rawAltitude)
    {
        float altChange = abs(rawAltitude - lastRawAltitude);
        if (altChange < cfg.stabilityThreshold)
        {
            stableReadings++;
        }
        else
        {
            stableReadings = 0;
        }

        float baselineAlpha = (stableReadings > STABLE_THRESHOLD) ? 0.05 : 0.001;
        adaptiveBaseline = adaptiveBaseline * (1.0 - baselineAlpha) + telemetry.pressure * baselineAlpha;
        lastRawAltitude = rawAltitude;
    }

    void processTelemetryOutput(float rawAltitude, unsigned long now)
    {
        telemetry.altitude = kalmanUpdate(&kAlt, rawAltitude);

        if (abs(telemetry.altitude) < cfg.deadZone)
        {
            telemetry.altitude = 0.00;
        }

        telemetry.temperature = readTemperature();
        telemetry.isStable = (stableReadings > STABLE_THRESHOLD);

        if (isLogging)
        {
            float relTime = (now - logStartTime) / 1000.0;
            Serial.print("[");
            Serial.print(relTime, 1);
            Serial.print("s] ");
            Serial.print("Alt: ");
            Serial.print(telemetry.altitude, 2);
            Serial.print("m | ");
            Serial.print("P: ");
            Serial.print(telemetry.pressure, 1);
            Serial.print("Pa | ");
            Serial.println(telemetry.isStable ? "STABLE" : "MOVING");
        }
    }

    void performCalculations(unsigned long now)
    {
        if (sampleCount > 0)
        {
            telemetry.pressure = pressureAccumulator / (double)sampleCount;
        }

        if (!isCalibrated)
        {
            pressureAccumulator = 0;
            sampleCount = 0;
            return;
        }

        // Барометрическая формула с использованием конфига
        float rawAltitude = cfg.altFactor * (1.0 - pow(telemetry.pressure / adaptiveBaseline, cfg.altExponent));

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