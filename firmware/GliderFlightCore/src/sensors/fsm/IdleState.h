#ifndef IDLE_STATE_H
#define IDLE_STATE_H

#include "CalibrationState.h"

namespace Sensors
{
    class IdleState : public CalibrationState
    {
    public:
        void update(unsigned long now) override {}
        int getProgress() override { return 0; }
        String getPhaseName() override { return "idle"; }
        bool isMeasuring() override { return false; }
        bool isIdle() override { return true; }
        void serialize(JsonObject &doc) override
        {
            doc["calibrating"] = false;
            doc["calib_phase"] = "idle";
            doc["calib_progress"] = 0;
        }
    };
}

#endif