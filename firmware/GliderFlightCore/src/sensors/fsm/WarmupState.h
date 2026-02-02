#ifndef WARMUP_STATE_H
#define WARMUP_STATE_H

#include "CalibrationState.h"
#include "../BarometerDriver.h"

namespace Sensors
{
    class WarmupState : public CalibrationState
    {
    private:
        unsigned long startTime;
        unsigned long lastSample;

    public:
        void onEnter() override { startTime = lastSample = millis(); }
        void update(unsigned long now) override
        {
            if (now - lastSample >= 50)
            {
                lastSample = now;
                readPressure();
                readTemperature();
            }
            if (now - startTime >= 10000)
            {
                Serial.println("[Sensors] Термостабилизация завершена -> Сбор данных");
                transitionToMeasuring();
            }
        }
        int getProgress() override { return constrain(((millis() - startTime) * 100) / 10000, 0, 99); }
        String getPhaseName() override { return "stabilization"; }
        void serialize(JsonObject &doc) override
        {
            doc["calibrating"] = true;
            doc["calib_phase"] = getPhaseName();
            doc["calib_progress"] = getProgress();
        }
    };
}

#endif