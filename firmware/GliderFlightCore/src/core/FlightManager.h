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
        STATE_SETUP, // 0: Настройка
        STATE_ARMED, // 1: Взведен
        STATE_FLIGHT // 2: Полет
    };

    FlightState currentState = STATE_SETUP;

    bool lastHallState = HIGH;
    unsigned long pressStartTime = 0;
    bool isWaitRelease = false;

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
            break;

        case STATE_ARMED:
            Serial.println("--- System Mode: ARMED (Ready to Launch) ---");
            // Если вернулись из полета — включаем Wi-Fi обратно
            if (oldState == STATE_FLIGHT)
            {
                Network::setupWiFi();
            }
            break;

        case STATE_FLIGHT:
            Serial.println("--- System Mode: FLIGHT (Wi-Fi OFF) ---");
            Network::stopWiFi();
            break;
        }
    }

    /**
     * Обработка короткого нажатия (Цикл вперед)
     */
    void handleShortPress()
    {
        if (currentState == STATE_SETUP)
        {
            transitionTo(STATE_ARMED);
        }
        else if (currentState == STATE_ARMED)
        {
            transitionTo(STATE_FLIGHT);
        }
    }

    /**
     * Обработка длинного нажатия (Цикл назад / Отмена)
     */
    void handleLongPress()
    {
        if (currentState == STATE_ARMED)
        {
            Serial.println("[Flight] Отмена взведения -> SETUP");
            transitionTo(STATE_SETUP);
        }
        else if (currentState == STATE_FLIGHT)
        {
            Serial.println("[Flight] Прерывание полета -> ARMED");
            transitionTo(STATE_ARMED);
        }
    }

    void setup()
    {
        pinMode(PIN_HALL, INPUT_PULLUP);
        lastHallState = digitalRead(PIN_HALL);
        Serial.println("[Flight] Менеджер полета инициализирован.");
    }

    void update()
    {
        bool currentHallState = digitalRead(PIN_HALL);
        unsigned long now = millis();

        // Детекция нажатия (LOW)
        if (currentHallState == LOW && lastHallState == HIGH)
        {
            pressStartTime = now;
            isWaitRelease = true;
        }
        // Детекция отпускания (HIGH)
        else if (currentHallState == HIGH && lastHallState == LOW)
        {
            unsigned long duration = now - pressStartTime;

            if (duration >= LONG_PRESS_MS)
            {
                handleLongPress();
            }
            else if (duration >= DEBOUNCE_MS)
            {
                handleShortPress();
            }
            isWaitRelease = false;
        }

        // Автоматическое срабатывание длинного нажатия без отпускания
        if (isWaitRelease && (now - pressStartTime >= LONG_PRESS_MS))
        {
            handleLongPress();
            isWaitRelease = false;
        }

        lastHallState = currentHallState;
    }
}

#endif