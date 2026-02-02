#ifndef FLIGHT_MODE_H
#define FLIGHT_MODE_H

#include "../../config/Config.h"

namespace Flight
{
    using namespace Config;

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

    // Опережающее объявление функции перехода
    void transitionTo(FlightMode *newMode);

    // Глобальные указатели на объекты (будут определены в FlightManager.h)
    class SetupMode;
    class ArmedMode;
    class InFlightMode;
    extern SetupMode setupModeObj;
    extern ArmedMode armedModeObj;
    extern InFlightMode inFlightModeObj;
}

#endif