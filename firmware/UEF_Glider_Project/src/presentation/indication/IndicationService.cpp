#include "IndicationService.h"

namespace presentation::indication
{
    IndicationService::IndicationService(drivers::DualLed &led)
        : _led(&led),
          _setupPattern(true, false),      // SETUP: Только Цвет 1
          _armedPattern(500, false, true), // ARMED: Цвет 2, 1Гц
          _flightPattern(false, true),     // FLIGHT: Цвет 2, Heartbeat
          _calibPattern(50, true, true),   // CALIB: Смешивание (C1+C2), 10Гц
          _errorPattern(50, true, false)   // ERROR: Цвет 1, Rapid
    {
        _currentPattern = &_setupPattern;
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
            setPattern(_setupPattern);
            break;
        case FlightMode::ARMED:
            setPattern(_armedPattern);
            break;
        case FlightMode::IN_FLIGHT:
            setPattern(_flightPattern);
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
        // Кратковременная вспышка при клике (опционально, не мешает основным режимам)
        if (e.gesture == application::events::HallGesture::CLICK)
        {
            (void)_led->set(true, true);
        }
    }

    void IndicationService::execute(uint32_t now)
    {
        if (_isError)
        {
            _errorPattern.update(now, *_led);
            return;
        }

        if (_isCalibrating)
        {
            _calibPattern.update(now, *_led);
            return;
        }

        _currentPattern->update(now, *_led);
    }
}