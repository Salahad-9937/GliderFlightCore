#include "IndicationService.h"
#include <Arduino.h>

namespace presentation::indication
{
    IndicationService::IndicationService(drivers::LedChannel &led)
        : _led(&led),
          _slowBlink(500),
          _fastBlink(150),
          _rapidBlink(50),
          _steadyOn(true),
          _steadyOff(false)
    {
        _currentPattern = &_slowBlink;
    }

    void IndicationService::setPattern(IIndicationPattern &pattern)
    {
        if (_currentPattern != &pattern)
        {
            _currentPattern = &pattern;
            _currentPattern->reset();
        }
    }

    void IndicationService::onTypedEvent(const application::events::FlightStateEvent &e)
    {
        using application::events::FlightMode;
        switch (e.mode)
        {
        case FlightMode::SETUP:
            setPattern(_slowBlink);
            break;
        case FlightMode::ARMED:
            setPattern(_fastBlink);
            break; // Упрощено для примера
        case FlightMode::IN_FLIGHT:
            setPattern(_steadyOn);
            break;
        }
    }

    void IndicationService::onTypedEvent(const application::events::CalibrationEvent &e)
    {
        _isCalibrating = (e.status != application::events::CalibrationStatus::IDLE &&
                          e.status != application::events::CalibrationStatus::SUCCESS);
    }

    void IndicationService::onTypedEvent(const application::events::HallEvent &e)
    {
        if (e.gesture == application::events::HallGesture::CLICK)
        {
            _led->on(); // Визуальный фидбек
        }
    }

    void IndicationService::execute(uint32_t now)
    {
        if (_isError)
        {
            _rapidBlink.update(now, *_led);
            return;
        }

        if (_isCalibrating)
        {
            _fastBlink.update(now, *_led);
            return;
        }

        _currentPattern->update(now, *_led);
    }
}