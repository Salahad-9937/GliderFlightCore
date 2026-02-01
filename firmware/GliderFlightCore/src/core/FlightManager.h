#ifndef FLIGHT_MANAGER_H
#define FLIGHT_MANAGER_H

#include <Arduino.h>
#include "../config/Config.h"
#include "../network/WiFiManager.h"
#include "Sensors.h"

namespace Flight
{
    using namespace Config;

    class FlightMode;

    /**
     * Инкапсуляция физики датчика Холла.
     */
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

    /**
     * Интерфейс состояний полета.
     */
    class FlightMode
    {
    public:
        virtual void onEnter(FlightState oldState) = 0;
        virtual void update(unsigned long now) = 0;
        virtual void onDoubleClick() {}
        virtual void onLongPress() {}
        virtual void onRelease(bool wasReady) {}
        virtual FlightState getType() = 0;
    };

    // --- Определения классов состояний (только интерфейс) ---

    class SetupMode : public FlightMode
    {
    public:
        FlightState getType() override { return STATE_SETUP; }
        void onEnter(FlightState oldState) override;
        void update(unsigned long now) override {}
        void onLongPress() override;
    };

    class ArmedMode : public FlightMode
    {
    public:
        FlightState getType() override { return STATE_ARMED; }
        void onEnter(FlightState oldState) override;
        void update(unsigned long now) override {}
        void onDoubleClick() override;
        void onRelease(bool wasReady) override;
    };

    class InFlightMode : public FlightMode
    {
    public:
        FlightState getType() override { return STATE_FLIGHT; }
        void onEnter(FlightState oldState) override;
        void update(unsigned long now) override {}
        void onDoubleClick() override;
    };

    // Глобальные объекты состояний
    extern SetupMode setupModeObj;
    extern ArmedMode armedModeObj;
    extern InFlightMode inFlightModeObj;

    extern FlightMode *currentModePtr;
    extern HallSensorHandler hallHandler;

    // --- Реализация логики переходов и методов (после полных определений классов) ---

    void transitionTo(FlightMode *newMode)
    {
        if (currentModePtr == newMode)
            return;
        FlightState oldType = (currentModePtr) ? currentModePtr->getType() : STATE_SETUP;
        currentModePtr = newMode;
        Sensors::sys.flightState = currentModePtr->getType();
        currentModePtr->onEnter(oldType);
    }

    // Реализация SetupMode
    void SetupMode::onEnter(FlightState oldState)
    {
        Serial.println("--- System Mode: SETUP (Wi-Fi ON) ---");
        if (oldState == STATE_FLIGHT)
            Network::setupWiFi();
    }
    void SetupMode::onLongPress() { transitionTo(&armedModeObj); }

    // Реализация ArmedMode
    void ArmedMode::onEnter(FlightState oldState)
    {
        Serial.println("--- System Mode: ARMED (Ready to Launch) ---");
        if (oldState == STATE_FLIGHT)
            Network::setupWiFi();
    }
    void ArmedMode::onDoubleClick()
    {
        Serial.println("[Flight] Возврат: ARMED -> SETUP");
        transitionTo(&setupModeObj);
    }
    void ArmedMode::onRelease(bool wasReady)
    {
        if (wasReady)
            transitionTo(&inFlightModeObj);
    }

    // Реализация InFlightMode
    void InFlightMode::onEnter(FlightState oldState)
    {
        Serial.println("--- System Mode: FLIGHT (Wi-Fi OFF) ---");
        Network::stopWiFi();
    }
    void InFlightMode::onDoubleClick()
    {
        Serial.println("[Flight] Прерывание: FLIGHT -> ARMED");
        transitionTo(&armedModeObj);
    }

    // Реализация методов HallSensorHandler
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

    // Инициализация объектов
    SetupMode setupModeObj;
    ArmedMode armedModeObj;
    InFlightMode inFlightModeObj;
    FlightMode *currentModePtr = nullptr;
    HallSensorHandler hallHandler(pins.hall);

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