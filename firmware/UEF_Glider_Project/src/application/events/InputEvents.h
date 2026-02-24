#ifndef APPLICATION_INPUT_EVENTS_H
#define APPLICATION_INPUT_EVENTS_H

#include "../../core2/messaging/Event.h"

namespace application::events
{
    /**
     * Типы жестов датчика Холла.
     */
    enum class HallGesture : uint8_t
    {
        CLICK,            ///< Одиночный короткий клик
        DOUBLE_CLICK,     ///< Двойной клик
        LONG_PRESS_START, ///< Начало долгого удержания (порог пройден)
        RELEASE           ///< Магнит убран
    };

    /**
     * Событие датчика Холла для рассылки через EventBus.
     */
    struct HallEvent : public core2::event::Base
    {
        static constexpr core2::EventID ID = 101;

        HallGesture gesture;
        uint32_t duration; // Длительность удержания в мс

        explicit HallEvent(HallGesture gestureType, uint32_t durationMs = 0)
            : gesture(gestureType), duration(durationMs) {}
    };
}

#endif