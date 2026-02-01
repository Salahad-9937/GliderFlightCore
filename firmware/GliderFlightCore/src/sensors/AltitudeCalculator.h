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

    extern CalibrationData calData;
    const AltimeterConfig cfg;
    TelemetryData telemetry;
    PressureSampler sampler;
    StabilityMonitor stability(cfg.stabilityThreshold);
    KalmanState kAlt = {0.05, 0.3, 0, 1, 0};
    unsigned long logStartTime = 0;
    unsigned long last_log_time = 0;

    void updateAdaptiveBaseline(float alpha)
    {
        calData.adaptiveBaseline = calData.adaptiveBaseline * (1.0 - alpha) + telemetry.pressure * alpha;
    }

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
            Serial.print("m | P: ");
            Serial.print(telemetry.pressure, 1);
            Serial.print("Pa | ");
            Serial.println(telemetry.isStable ? "STABLE" : "MOVING");
        }
    }

    void processTelemetryOutput(float rawAltitude, unsigned long now)
    {
        telemetry.altitude = kalmanUpdate(&kAlt, rawAltitude);
        if (abs(telemetry.altitude) < cfg.deadZone)
            telemetry.altitude = 0.00;
        telemetry.temperature = readTemperature();
        telemetry.isStable = stability.isStable();
        logTelemetry(now);
    }

    void performCalculations(unsigned long now)
    {
        telemetry.pressure = sampler.getAverageAndReset();
        if (!sys.calibrated)
            return;
        float rawAltitude = cfg.altFactor * (1.0 - pow(telemetry.pressure / calData.adaptiveBaseline, cfg.altExponent));
        float alpha = stability.process(rawAltitude);
        updateAdaptiveBaseline(alpha);
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