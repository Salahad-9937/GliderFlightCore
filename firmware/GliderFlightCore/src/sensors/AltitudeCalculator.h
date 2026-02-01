#ifndef ALTITUDE_CALCULATOR_H
#define ALTITUDE_CALCULATOR_H

#include <math.h>
#include "BarometerDriver.h"
#include "KalmanFilter.h"
#include "Calibration.h"
#include "TelemetryData.h"
#include "../config/Config.h"

namespace Sensors
{

    class PressureSampler
    {
        double accumulator = 0;
        uint32_t count = 0;

    public:
        void add(double p)
        {
            accumulator += p;
            count++;
        }
        double getAverageAndReset()
        {
            if (count == 0)
                return 0;
            double avg = accumulator / (double)count;
            accumulator = 0;
            count = 0;
            return avg;
        }
        void reset()
        {
            accumulator = 0;
            count = 0;
        }
    };

    struct AltimeterConfig
    {
        const float altFactor = 44330.0;
        const float altExponent = 0.190295;
        const float stabilityThreshold = 0.25;
        const float deadZone = 0.12;
        const unsigned long interval = BARO_INTERVAL;
    };

    // Внешние зависимости
    extern CalibrationData calData;

    const AltimeterConfig cfg;
    TelemetryData telemetry;
    PressureSampler sampler;
    KalmanState kAlt = {0.05, 0.3, 0, 1, 0};

    float lastRawAltitude = 0;
    int stableReadings = 0;
    unsigned long logStartTime = 0;
    unsigned long last_log_time = 0;

    /**
     * Обновление адаптивного базиса (Extract Method)
     */
    void updateAdaptiveBaseline(float rawAltitude)
    {
        float altChange = abs(rawAltitude - lastRawAltitude);
        stableReadings = (altChange < cfg.stabilityThreshold) ? stableReadings + 1 : 0;

        float alpha = (stableReadings > STABLE_THRESHOLD) ? 0.05 : 0.001;
        calData.adaptiveBaseline = calData.adaptiveBaseline * (1.0 - alpha) + telemetry.pressure * alpha;
        lastRawAltitude = rawAltitude;
    }

    /**
     * Вывод логов в Serial (Extract Method)
     */
    void logTelemetry(unsigned long now)
    {
        if (sys.logging)
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

    /**
     * Применение фильтрации и расчет финальных значений (Extract Method)
     */
    void processTelemetryOutput(float rawAltitude, unsigned long now)
    {
        telemetry.altitude = kalmanUpdate(&kAlt, rawAltitude);

        // Применение "мертвой зоны"
        if (abs(telemetry.altitude) < cfg.deadZone)
            telemetry.altitude = 0.00;

        telemetry.temperature = readTemperature();
        telemetry.isStable = (stableReadings > STABLE_THRESHOLD);

        logTelemetry(now);
    }

    /**
     * Основной расчетный цикл
     */
    void performCalculations(unsigned long now)
    {
        telemetry.pressure = sampler.getAverageAndReset();
        if (!sys.calibrated)
            return;

        // Расчет сырой высоты
        float rawAltitude = cfg.altFactor * (1.0 - pow(telemetry.pressure / calData.adaptiveBaseline, cfg.altExponent));

        updateAdaptiveBaseline(rawAltitude);
        processTelemetryOutput(rawAltitude, now);
    }

    void updateAltitude()
    {
        if (!sys.hardwareOK || !sys.monitoring)
            return;

        sampler.add(readPressure());
        unsigned long now = millis();

        if (now - last_log_time >= cfg.interval)
        {
            last_log_time = now;
            performCalculations(now);
        }
    }
}
#endif