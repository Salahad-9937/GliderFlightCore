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

    // Состояние датчика
    bool lastHallState = HIGH;
    unsigned long pressStartTime = 0;
    unsigned long lastReleaseTime = 0;

    // Флаги логики
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
            if (oldState != STATE_SETUP)
                Network::setupWiFi();
            break;

        case STATE_ARMED:
            Serial.println("--- System Mode: ARMED (Ready to Launch) ---");
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
     * Переход вперед (через Long Press)
     */
    void handleForwardTransition()
    {
        if (currentState == STATE_SETUP)
        {
            transitionTo(STATE_ARMED);
        }
    }

    /**
     * Переход назад (через Double Click)
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
        pinMode(PIN_HALL, INPUT_PULLUP);
        lastHallState = digitalRead(PIN_HALL);
        Serial.println("[Flight] Менеджер полета (Advanced Hall Logic) готов.");
    }

    void update()
    {
        bool currentHallState = digitalRead(PIN_HALL);
        unsigned long now = millis();

        // 1. Детекция нажатия (Магнит поднесен)
        if (currentHallState == LOW && lastHallState == HIGH)
        {
            pressStartTime = now;
            isHolding = true;
            readyForFlightRelease = false;
        }

        // 2. Логика во время удержания
        if (isHolding)
        {
            unsigned long holdDuration = now - pressStartTime;

            if (holdDuration >= LONG_PRESS_MS)
            {
                if (currentState == STATE_SETUP)
                {
                    handleForwardTransition();
                    isHolding = false; // Сбрасываем, чтобы не срабатывало по кругу
                }
                else if (currentState == STATE_ARMED)
                {
                    // Для полета только взводим флаг, ждем отпускания
                    if (!readyForFlightRelease)
                    {
                        Serial.println("[Flight] Система готова к пуску (отпустите магнит)");
                        readyForFlightRelease = true;
                    }
                }
            }
        }

        // 3. Детекция отпускания (Магнит удален)
        if (currentHallState == HIGH && lastHallState == LOW)
        {
            unsigned long pressDuration = now - pressStartTime;
            isHolding = false;

            if (readyForFlightRelease)
            {
                // Специфический переход в полет по отпусканию
                if (currentState == STATE_ARMED)
                {
                    transitionTo(STATE_FLIGHT);
                }
                readyForFlightRelease = false;
            }
            else if (pressDuration >= DEBOUNCE_MS && pressDuration < LONG_PRESS_MS)
            {
                // Считаем клики для двойного нажатия
                clickCount++;
                lastReleaseTime = now;
            }
        }

        // 4. Обработка двойного клика по таймауту
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