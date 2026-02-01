#ifndef FLIGHT_MANAGER_H
#define FLIGHT_MANAGER_H

#include <Arduino.h>
#include "../config/Config.h"
#include "../network/WiFiManager.h"
#include "Sensors.h"

namespace Flight
{
    enum FlightState
    {
        STATE_SETUP,
        STATE_ARMED,
        STATE_FLIGHT
    };

    FlightState currentState = STATE_SETUP;

    bool lastHallState = HIGH;
    unsigned long pressStartTime = 0;
    unsigned long lastReleaseTime = 0;

    bool isHolding = false;
    bool readyForFlightRelease = false;
    int clickCount = 0;

    /**
     * Логика переходов между состояниями
     */
    void transitionTo(FlightState newState)
    {
        if (currentState == newState)
            return;

        FlightState oldState = currentState;
        currentState = newState;
        Sensors::sys.flightState = (int)newState;

        switch (newState)
        {
        case STATE_SETUP:
            Serial.println("--- System Mode: SETUP (Wi-Fi ON) ---");
            // ИСПРАВЛЕНО: Включаем Wi-Fi только если вернулись из полета.
            // При переходе ARMED -> SETUP Wi-Fi уже работает, трогать не надо.
            if (oldState == STATE_FLIGHT)
                Network::setupWiFi();
            break;

        case STATE_ARMED:
            Serial.println("--- System Mode: ARMED (Ready to Launch) ---");
            // Аналогично: включаем только при возврате из полета
            if (oldState == STATE_FLIGHT)
                Network::setupWiFi();
            break;

        case STATE_FLIGHT:
            Serial.println("--- System Mode: FLIGHT (Wi-Fi OFF) ---");
            Network::stopWiFi();
            break;
        }
    }

    /**
     * Переход вперед (Long Press)
     */
    void handleForwardTransition()
    {
        if (currentState == STATE_SETUP)
        {
            transitionTo(STATE_ARMED);
        }
    }

    /**
     * Переход назад (Double Click)
     */
    void handleBackwardTransition()
    {
        if (currentState == STATE_ARMED)
        {
            Serial.println("[Flight] Возврат: ARMED -> SETUP");
            transitionTo(STATE_SETUP);
        }
        else if (currentState == STATE_FLIGHT)
        {
            Serial.println("[Flight] Прерывание: FLIGHT -> ARMED");
            transitionTo(STATE_ARMED);
        }
    }

    void setup()
    {
        pinMode(pins.hall, INPUT_PULLUP);
        lastHallState = digitalRead(pins.hall);
        Serial.printf("[Flight] Hall sensor initialized on GPIO %d\n", pins.hall);
    }

    void update()
    {
        bool currentHallState = digitalRead(pins.hall);
        unsigned long now = millis();

        // 1. Детекция нажатия
        if (currentHallState == LOW && lastHallState == HIGH)
        {
            pressStartTime = now;
            isHolding = true;
            readyForFlightRelease = false;
        }

        // 2. Логика удержания
        if (isHolding)
        {
            unsigned long holdDuration = now - pressStartTime;
            if (holdDuration >= LONG_PRESS_MS)
            {
                if (currentState == STATE_SETUP)
                {
                    handleForwardTransition();
                    isHolding = false;
                }
                else if (currentState == STATE_ARMED && !readyForFlightRelease)
                {
                    Serial.println("[Flight] Система готова к пуску (отпустите магнит)");
                    readyForFlightRelease = true;
                }
            }
        }

        // 3. Детекция отпускания
        if (currentHallState == HIGH && lastHallState == LOW)
        {
            unsigned long pressDuration = now - pressStartTime;
            isHolding = false;

            if (readyForFlightRelease)
            {
                if (currentState == STATE_ARMED)
                    transitionTo(STATE_FLIGHT);
                readyForFlightRelease = false;
            }
            else if (pressDuration >= DEBOUNCE_MS && pressDuration < LONG_PRESS_MS)
            {
                clickCount++;
                lastReleaseTime = now;
            }
        }

        // 4. Обработка двойного клика
        if (clickCount > 0 && (now - lastReleaseTime >= DOUBLE_CLICK_MS))
        {
            if (clickCount == 2)
            {
                handleBackwardTransition();
            }
            clickCount = 0;
        }

        lastHallState = currentHallState;
    }
}
#endif