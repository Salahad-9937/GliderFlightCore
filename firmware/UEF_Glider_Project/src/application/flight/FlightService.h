#ifndef APPLICATION_FLIGHT_FLIGHT_SERVICE_H
#define APPLICATION_FLIGHT_FLIGHT_SERVICE_H

#include "../../core2/engine/StateMachine.h"
#include "../../core2/engine/Scheduler.h"
#include "../../core2/messaging/EventBus.h"
#include "../../core2/messaging/EventListener.h"
#include "../events/InputEvents.h"
#include "../events/FlightEvents.h"
#include "states/SetupState.h"
#include "states/ArmedState.h"
#include "states/InFlightState.h"

namespace application::flight
{
    using namespace core2;
    using namespace application::events;

    /**
     * @brief Координатор полетных режимов.
     */
    class FlightService : public ITask, public TypedEventListener<HallEvent>
    {
    public:
        explicit FlightService(hal::INetwork &net,
                               hal::IActuator &servo,
                               hal::IStorage &storage,
                               ProgramManager &progManager,
                               application::telemetry::TelemetryService &telemetry,
                               EventBus<> &bus)
            : _bus(&bus),
              _fsm(Registry::getLogger()),
              _setupState(),
              _armedState(),
              _inFlightState(net, servo, progManager, storage, telemetry)
        {
            // Связывание состояний для переходов
            _setupState.setArmedState(&_armedState);
            _armedState.setInFlightState(&_inFlightState);
        }

        auto init() -> void
        {
            changeState(&_setupState, FlightMode::SETUP);
        }

        /**
         * Обработка жестов через полиморфизм состояний.
         */
        void onTypedEvent(const HallEvent &event) override
        {
            // Глобальный жест сброса в SETUP
            if (event.gesture == HallGesture::DOUBLE_CLICK)
            {
                changeState(&_setupState, FlightMode::SETUP);
                return;
            }

            // Делегирование обработки жеста текущему состоянию
            // NOLINTNEXTLINE(cppcoreguidelines-pro-type-static-cast-downcast)
            auto *current = static_cast<BaseFlightState *>(_fsm.getCurrentState());
            if (current != nullptr)
            {
                BaseFlightState *next = current->handleGesture(event.gesture);
                if (next != nullptr)
                {
                    // Определяем режим для события на основе целевого состояния
                    FlightMode nextMode = FlightMode::SETUP;
                    if (next == &_armedState)
                    {
                        nextMode = FlightMode::ARMED;
                    }
                    else if (next == &_inFlightState)
                    {
                        nextMode = FlightMode::IN_FLIGHT;
                    }

                    changeState(next, nextMode);
                }
            }
        }

        void execute(uint32_t now) override
        {
            _fsm.update(now);
        }

        [[nodiscard]] auto isConfigLocked() const -> bool
        {
            // NOLINTNEXTLINE(cppcoreguidelines-pro-type-static-cast-downcast)
            auto *current = static_cast<BaseFlightState *>(_fsm.getCurrentState());
            return (current != nullptr) ? current->isConfigLocked() : true;
        }

        [[nodiscard]] auto getCurrentMode() const -> FlightMode { return _currentMode; }

    private:
        auto changeState(BaseFlightState *newState, FlightMode mode) -> void
        {
            _fsm.transitionTo(newState);
            _currentMode = mode;
            _bus->publish(FlightStateEvent::ID, FlightStateEvent(mode));
        }

        EventBus<> *_bus = nullptr;
        StateMachine _fsm;

        SetupState _setupState;
        ArmedState _armedState;
        InFlightState _inFlightState;

        FlightMode _currentMode = FlightMode::SETUP;
    };
}

#endif