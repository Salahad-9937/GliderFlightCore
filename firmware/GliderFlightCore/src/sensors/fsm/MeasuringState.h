#ifndef MEASURING_STATE_H
#define MEASURING_STATE_H

#include "CalibrationState.h"
#include "../BarometerDriver.h"
#include "../CalibrationData.h"
#include "../KalmanFilter.h"

namespace Sensors
{
    class MeasuringState : public CalibrationState
    {
    private:
        int samples = 0;
        double sum = 0;
        unsigned long lastSample;

    public:
        void onEnter() override
        {
            samples = 0;
            sum = 0;
            lastSample = millis();
        }
        void update(unsigned long now) override
        {
            if (now - lastSample >= 5)
            {
                lastSample = now;
                sum += readPressure();
                samples++;
                if (samples >= 2000)
                {
                    calData.basePressure = sum / 2000.0;
                    calData.adaptiveBaseline = calData.basePressure;
                    kAlt.x = 0;
                    sys.calibrated = true;
                    Serial.print("[Sensors] Калибровка завершена. База: ");
                    Serial.println(calData.basePressure, 2);
                    transitionToIdle();
                }
            }
        }
        int getProgress() override { return constrain((samples * 100) / 2000, 0, 99); }
        String getPhaseName() override { return "measuring"; }
        void serialize(JsonObject &doc) override
        {
            doc["calibrating"] = true;
            doc["calib_phase"] = getPhaseName();
            doc["calib_progress"] = getProgress();
        }
    };
}

#endif