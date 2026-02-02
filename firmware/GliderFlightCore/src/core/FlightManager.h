#ifndef FLIGHT_MANAGER_H
#define FLIGHT_MANAGER_H

#include <Arduino.h>
#include "fsm/FlightMode.h"
#include "fsm/SetupMode.h"
#include "fsm/ArmedMode.h"
#include "fsm/InFlightMode.h"
#include "HallHandler.h"
#include "Sensors.h"

namespace Flight
{
    // Инициализация глобальных объектов
    SetupMode setupModeObj;
    ArmedMode armedModeObj;
    InFlightMode inFlightModeObj;

    FlightMode *currentModePtr = nullptr;
    HallSensorHandler hallHandler(pins.hall);

    /**
     * Реализация функции перехода
     */
    void transitionTo(FlightMode *newMode)
    {
        if (currentModePtr == newMode)
            return;
        FlightState oldType = (currentModePtr) ? currentModePtr->getType() : STATE_SETUP;
        currentModePtr = newMode;
        Sensors::sys.flightState = currentModePtr->getType();
        currentModePtr->onEnter(oldType);
    }

    // Реализация методов HallSensorHandler (вынесена сюда, чтобы видеть типы режимов)
    void HallSensorHandler::handleHolding(unsigned long now, FlightMode *currentMode)
    {
        unsigned long holdDuration = now - _pressStartTime;
        if (holdDuration >= LONG_PRESS_MS)
        {
            if (currentMode->getType() == STATE_SETUP)
            {
                currentMode->onLongPress();
                _isHolding = false;
            }
            else if (currentMode->getType() == STATE_ARMED && !_readyForFlightRelease)
            {
                Serial.println("[Flight] Система готова к пуску (отпустите магнит)");
                _readyForFlightRelease = true;
            }
        }
    }

    void HallSensorHandler::processRelease(unsigned long now, FlightMode *currentMode)
    {
        unsigned long pressDuration = now - _pressStartTime;
        _isHolding = false;
        if (_readyForFlightRelease)
        {
            currentMode->onRelease(true);
            _readyForFlightRelease = false;
        }
        else if (pressDuration >= DEBOUNCE_MS && pressDuration < LONG_PRESS_MS)
        {
            _clickCount++;
            _lastReleaseTime = now;
        }
    }

    void HallSensorHandler::processClickTimeout(unsigned long now, FlightMode *currentMode)
    {
        if (_clickCount > 0 && (now - _lastReleaseTime >= DOUBLE_CLICK_MS))
        {
            if (_clickCount == 2)
                currentMode->onDoubleClick();
            _clickCount = 0;
        }
    }

    // Главные функции API
    void setup()
    {
        hallHandler.init();
        transitionTo(&setupModeObj);
    }

    void update()
    {
        unsigned long now = millis();
        hallHandler.update(now, currentModePtr);
        currentModePtr->update(now);
    }
}
#endif