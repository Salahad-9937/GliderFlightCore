#ifndef SETUP_MODE_H
#define SETUP_MODE_H

#include "FlightMode.h"
#include <Arduino.h>
#include "../../network/WiFiManager.h"

namespace Flight
{
    class SetupMode : public FlightMode
    {
    public:
        FlightState getType() override { return STATE_SETUP; }
        void onEnter(FlightState oldState) override
        {
            Serial.println("--- System Mode: SETUP (Wi-Fi ON) ---");
            if (oldState == STATE_FLIGHT)
                Network::setupWiFi();
        }
        void update(unsigned long now) override {}
        void onLongPress() override { transitionTo((FlightMode *)&armedModeObj); }
    };
}

#endif