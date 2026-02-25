#ifndef PRESENTATION_INDICATION_SERVICE_H
#define PRESENTATION_INDICATION_SERVICE_H

#include "../../core2/engine/Scheduler.h"
#include "../../core2/messaging/EventListener.h"
#include "../../drivers/led/DualLed.h"
#include "../../application/events/FlightEvents.h"
#include "../../application/events/CalibrationEvents.h"
#include "../../application/events/InputEvents.h"
#include "IndicationPattern.h"

namespace presentation::indication
{
    /**
     * @brief Сервис индикации режимов полета и калибровки.
     */
    class IndicationService : public core2::ITask,
                              public core2::TypedEventListener<application::events::FlightStateEvent>,
                              public core2::TypedEventListener<application::events::CalibrationEvent>,
                              public core2::TypedEventListener<application::events::HallEvent>
    {
    public:
        explicit IndicationService(drivers::DualLed &led);

        void execute(uint32_t now) override;
        void onTypedEvent(const application::events::FlightStateEvent &e) override;
        void onTypedEvent(const application::events::CalibrationEvent &e) override;
        void onTypedEvent(const application::events::HallEvent &e) override;

        void setError(bool hasError) { _isError = hasError; }

    private:
        void setPattern(IIndicationPattern &pattern);

        drivers::DualLed *_led;
        IIndicationPattern *_currentPattern;

        // Определение стратегий согласно ТЗ
        SteadyPattern _setupPattern;     // Цвет 1, постоянно
        BlinkPattern _armedPattern;      // Цвет 2, 1Гц (500мс)
        HeartbeatPattern _flightPattern; // Цвет 2, сердцебиение
        BlinkPattern _calibPattern;      // Оба цвета (смешивание), 10Гц (50мс)
        BlinkPattern _errorPattern;      // Цвет 1, быстро (50мс)

        bool _isError = false;
        bool _isCalibrating = false;
    };
}

#endif