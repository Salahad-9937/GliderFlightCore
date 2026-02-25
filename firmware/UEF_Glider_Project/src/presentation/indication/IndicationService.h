#ifndef PRESENTATION_INDICATION_SERVICE_H
#define PRESENTATION_INDICATION_SERVICE_H

#include "../../core2/engine/Scheduler.h"
#include "../../core2/messaging/EventListener.h"
#include "../../drivers/led/LedChannel.h"
#include "../../application/events/FlightEvents.h"
#include "../../application/events/CalibrationEvents.h"
#include "../../application/events/InputEvents.h"
#include "IndicationPattern.h"

namespace presentation::indication
{
    /**
     * @brief Сервис индикации.
     * Использует паттерн Strategy для переключения визуальных эффектов.
     */
    class IndicationService : public core2::ITask,
                              public core2::TypedEventListener<application::events::FlightStateEvent>,
                              public core2::TypedEventListener<application::events::CalibrationEvent>,
                              public core2::TypedEventListener<application::events::HallEvent>
    {
    public:
        explicit IndicationService(drivers::LedChannel &led);

        void execute(uint32_t now) override;
        void onTypedEvent(const application::events::FlightStateEvent &e) override;
        void onTypedEvent(const application::events::CalibrationEvent &e) override;
        void onTypedEvent(const application::events::HallEvent &e) override;
        void setError(bool hasError) { _isError = hasError; }

    private:
        void setPattern(IIndicationPattern &pattern);

        drivers::LedChannel *_led;
        IIndicationPattern *_currentPattern;

        // Статические стратегии (экономия памяти)
        BlinkPattern _slowBlink;
        BlinkPattern _fastBlink;
        BlinkPattern _rapidBlink;
        SteadyPattern _steadyOn;
        SteadyPattern _steadyOff;

        bool _isError = false;
        bool _isCalibrating = false;
    };
}

#endif