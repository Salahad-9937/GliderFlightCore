#include "IndicationService.h"
#include <Arduino.h>

namespace presentation::indication
{
    void IndicationService::onTypedEvent(const FlightStateEvent &e)
    {
        switch (e.mode)
        {
        case FlightMode::SETUP:
            _currentPattern = Pattern::SLOW_BLINK;
            break;
        case FlightMode::ARMED:
            _currentPattern = Pattern::HEARTBEAT;
            break;
        case FlightMode::IN_FLIGHT:
            _currentPattern = Pattern::STEADY_ON;
            break;
        }
    }

    void IndicationService::onTypedEvent(const CalibrationEvent &e)
    {
        _isCalibrating = (e.status != CalibrationStatus::IDLE &&
                          e.status != CalibrationStatus::SUCCESS &&
                          e.status != CalibrationStatus::ERROR);

        if (e.status == CalibrationStatus::ERROR)
            _isError = true;
    }

    void IndicationService::onTypedEvent(const HallEvent &e)
    {
        // Короткая вспышка при любом клике для визуального подтверждения
        if (e.gesture == HallGesture::CLICK || e.gesture == HallGesture::DOUBLE_CLICK)
        {
            _led->on();
            _lastToggleTime = millis() + 100; // Продлеваем фазу включения
        }
    }

    void IndicationService::execute(uint32_t now)
    {
        // Приоритеты индикации: Error > Calibrating > Flight Mode
        Pattern active = _currentPattern;
        if (_isError)
            active = Pattern::RAPID_FIRE;
        else if (_isCalibrating)
            active = Pattern::FAST_BLINK;

        switch (active)
        {
        case Pattern::SLOW_BLINK: // 500мс ВКЛ / 500мс ВЫКЛ
            if (now - _lastToggleTime >= 500)
            {
                _led->toggle();
                _lastToggleTime = now;
            }
            break;

        case Pattern::HEARTBEAT: // Двойной короткий импульс (Armed)
            if (now - _lastToggleTime >= 100)
            {
                _lastToggleTime = now;
                _phase = (_phase + 1) % 10;
                // Паттерн: ВКЛ, ВЫКЛ, ВКЛ, ВЫКЛ... (всего 10 фаз по 100мс)
                if (_phase == 0 || _phase == 2)
                    _led->on();
                else
                    _led->off();
            }
            break;

        case Pattern::STEADY_ON:
            _led->on();
            break;

        case Pattern::FAST_BLINK: // 100мс ВКЛ / 100мс ВЫКЛ
            if (now - _lastToggleTime >= 100)
            {
                _led->toggle();
                _lastToggleTime = now;
            }
            break;

        case Pattern::RAPID_FIRE: // 50мс ВКЛ / 50мс ВЫКЛ
            if (now - _lastToggleTime >= 50)
            {
                _led->toggle();
                _lastToggleTime = now;
            }
            break;

        case Pattern::OFF:
        default:
            _led->off();
            break;
        }
    }
}