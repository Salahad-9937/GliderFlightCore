#ifndef PRESENTATION_INDICATION_SERVICE_H
#define PRESENTATION_INDICATION_SERVICE_H

#include "../../core2/engine/Scheduler.h"
#include "../../core2/messaging/EventListener.h"
#include "../../drivers/led/LedChannel.h"
#include "../../application/events/FlightEvents.h"
#include "../../application/events/CalibrationEvents.h"
#include "../../application/events/InputEvents.h"

namespace presentation::indication
{
    using namespace core2;
    using namespace application::events;

    /**
     * @brief Сервис визуальной индикации состояний.
     * Слушает события системы и управляет светодиодом через паттерны.
     */
    class IndicationService : public ITask,
                              public TypedEventListener<FlightStateEvent>,
                              public TypedEventListener<CalibrationEvent>,
                              public TypedEventListener<HallEvent>
    {
    public:
        explicit IndicationService(drivers::LedChannel &led) : _led(&led) {}

        /**
         * @brief Реализация ITask. Обновляет состояние LED согласно таймерам.
         */
        void execute(uint32_t now) override;

        /**
         * @brief Обработка событий смены режима полета.
         */
        void onTypedEvent(const FlightStateEvent &e) override;

        /**
         * @brief Обработка событий калибровки.
         */
        void onTypedEvent(const CalibrationEvent &e) override;

        /**
         * @brief Обработка событий ввода (подтверждение кликов).
         */
        void onTypedEvent(const HallEvent &e) override;

        /**
         * @brief Принудительная установка режима ошибки.
         */
        void setError(bool hasError) { _isError = hasError; }

    private:
        enum class Pattern : uint8_t
        {
            OFF,
            SLOW_BLINK, // Setup
            HEARTBEAT,  // Armed
            STEADY_ON,  // Flight
            FAST_BLINK, // Calibrating
            RAPID_FIRE  // Error
        };

        void updatePattern(uint32_t now);

        drivers::LedChannel *_led;
        Pattern _currentPattern = Pattern::SLOW_BLINK;

        bool _isError = false;
        bool _isCalibrating = false;
        uint32_t _lastToggleTime = 0;
        uint16_t _phase = 0;
    };
}

#endif