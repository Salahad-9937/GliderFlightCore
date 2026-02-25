#ifndef APPLICATION_FLIGHT_EVENTS_H
#define APPLICATION_FLIGHT_EVENTS_H

#include "../../core2/messaging/Event.h"

namespace application::events
{
    /**
     * @brief Типы состояний полета для уведомления системы.
     */
    enum class FlightMode : uint8_t
    {
        SETUP,
        ARMED,
        IN_FLIGHT
    };

    /**
     * @brief Событие смены режима полета.
     */
    struct FlightStateEvent : public core2::event::Base
    {
        static constexpr core2::EventID ID = 103;

        FlightMode mode;

        // Исправлено: именование параметра согласно readability-identifier-length
        explicit FlightStateEvent(FlightMode newMode) : mode(newMode) {}
    };
}

#endif