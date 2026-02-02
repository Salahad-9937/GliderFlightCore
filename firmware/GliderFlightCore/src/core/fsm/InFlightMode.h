#ifndef IN_FLIGHT_MODE_H
#define IN_FLIGHT_MODE_H

#include "FlightMode.h"
#include <Arduino.h>
#include "../../network/WiFiManager.h"

namespace Flight
{
    class InFlightMode : public FlightMode
    {
    public:
        FlightState getType() override { return STATE_FLIGHT; }
        void onEnter(FlightState oldState) override
        {
            Serial.println("--- System Mode: FLIGHT (Wi-Fi OFF) ---");
            Network::stopWiFi();
        }
        void update(unsigned long now) override {}
        void onDoubleClick() override
        {
            Serial.println("[Flight] Прерывание: FLIGHT -> ARMED");
            transitionTo((FlightMode *)&armedModeObj);
        }
    };
}

#endif