#ifndef HALL_HANDLER_H
#define HALL_HANDLER_H

#include <Arduino.h>
#include "../config/Config.h"
#include "fsm/FlightMode.h"

namespace Flight
{
    class HallSensorHandler
    {
    private:
        Pin _pin;
        bool _lastState = HIGH;
        unsigned long _pressStartTime = 0;
        unsigned long _lastReleaseTime = 0;
        bool _isHolding = false;
        bool _readyForFlightRelease = false;
        int _clickCount = 0;

        void processPress(unsigned long now)
        {
            _pressStartTime = now;
            _isHolding = true;
            _readyForFlightRelease = false;
        }

        void handleHolding(unsigned long now, FlightMode *currentMode);
        void processRelease(unsigned long now, FlightMode *currentMode);
        void processClickTimeout(unsigned long now, FlightMode *currentMode);

    public:
        HallSensorHandler(Pin pin) : _pin(pin) {}
        void init()
        {
            pinMode(_pin, INPUT_PULLUP);
            _lastState = digitalRead(_pin);
            Serial.printf("[Flight] Hall sensor initialized on GPIO %d\n", _pin);
        }
        void update(unsigned long now, FlightMode *currentMode)
        {
            bool currentState = digitalRead(_pin);
            if (currentState == LOW && _lastState == HIGH)
                processPress(now);
            if (_isHolding)
                handleHolding(now, currentMode);
            if (currentState == HIGH && _lastState == LOW)
                processRelease(now, currentMode);
            processClickTimeout(now, currentMode);
            _lastState = currentState;
        }
    };
}

#endif