#ifndef ZEROING_STATE_H
#define ZEROING_STATE_H

#include "CalibrationState.h"
#include "../BarometerDriver.h"
#include "../CalibrationData.h"
#include "../KalmanFilter.h"

namespace Sensors
{
    class ZeroingState : public CalibrationState
    {
    private:
        int samples = 0;
        double sum = 0;

    public:
        void onEnter() override
        {
            samples = 0;
            sum = 0;
        }
        void update(unsigned long now) override
        {
            sum += readPressure();
            samples++;
            if (samples >= 500)
            {
                calData.adaptiveBaseline = sum / 500.0;
                kAlt.x = 0;
                stability.reset();
                sys.calibrated = true;
                Serial.print("[Sensors] Ноль установлен: ");
                Serial.println(calData.adaptiveBaseline, 2);
                transitionToIdle();
            }
        }
        int getProgress() override { return constrain((samples * 100) / 500, 0, 99); }
        String getPhaseName() override { return "zeroing"; }
        void serialize(JsonObject &doc) override
        {
            doc["calibrating"] = true;
            doc["calib_phase"] = getPhaseName();
            doc["calib_progress"] = getProgress();
        }
    };
}

#endif