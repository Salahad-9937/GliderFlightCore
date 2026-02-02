#ifndef ARMED_MODE_H
#define ARMED_MODE_H

#include "FlightMode.h"
#include <Arduino.h>
#include "../../network/WiFiManager.h"

namespace Flight
{
    class ArmedMode : public FlightMode
    {
    public:
        FlightState getType() override { return STATE_ARMED; }
        void onEnter(FlightState oldState) override
        {
            Serial.println("--- System Mode: ARMED (Ready to Launch) ---");
            if (oldState == STATE_FLIGHT)
                Network::setupWiFi();
        }
        void update(unsigned long now) override {}
        void onDoubleClick() override
        {
            Serial.println("[Flight] Возврат: ARMED -> SETUP");
            transitionTo((FlightMode *)&setupModeObj);
        }
        void onRelease(bool wasReady) override
        {
            if (wasReady)
                transitionTo((FlightMode *)&inFlightModeObj);
        }
    };
}

#endif