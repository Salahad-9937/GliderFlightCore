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
     * @brief Координатор полетных режимов с расширенным логированием.
     */
    class FlightService : public ITask, public TypedEventListener<HallEvent>
    {
    public:
        explicit FlightService(hal::INetwork &net, EventBus<> &bus)
            : _bus(&bus),
              _fsm(Registry::getLogger()),
              _setupState(),
              _armedState(),
              _inFlightState(net)
        {
        }

        auto init() -> void
        {
            changeState(&_setupState, FlightMode::SETUP);
        }

        /**
         * @brief Обработка жестов датчика Холла.
         */
        void onTypedEvent(const HallEvent &e) override
        {
            switch (e.gesture)
            {
            case HallGesture::DOUBLE_CLICK:
                Registry::getLogger().info("FSM: Обнаружен DOUBLE_CLICK -> Сброс в SETUP\n");
                changeState(&_setupState, FlightMode::SETUP);
                _readyToLaunch = false;
                break;

            case HallGesture::LONG_PRESS_START:
                handleLongPress();
                break;

            case HallGesture::RELEASE:
                handleRelease(e.duration);
                break;

            default:
                break;
            }
        }

        void execute(uint32_t now) override
        {
            _fsm.update(now);
        }

        [[nodiscard]] auto isConfigLocked() const -> bool
        {
            auto *current = static_cast<BaseFlightState *>(_fsm.getCurrentState());
            return current ? current->isConfigLocked() : true;
        }

        [[nodiscard]] auto getCurrentMode() const -> FlightMode { return _currentMode; }

    private:
        auto handleLongPress() -> void
        {
            auto *current = _fsm.getCurrentState();

            if (current == &_setupState)
            {
                Registry::getLogger().info("FSM: Удержание 3с в SETUP -> Переход в ARMED\n");
                changeState(&_armedState, FlightMode::ARMED);
            }
            else if (current == &_armedState)
            {
                Registry::getLogger().info("FSM: Удержание 3с в ARMED -> ТРИГГЕР ПУСКА ВЗВЕДЕН\n");
                _readyToLaunch = true;
            }
        }

        auto handleRelease(uint32_t duration) -> void
        {
            if (_readyToLaunch && _fsm.getCurrentState() == &_armedState)
            {
                Registry::getLogger().info("FSM: Магнит убран -> ЗАПУСК ПОГРАММЫ ПОЛЕТА\n");
                changeState(&_inFlightState, FlightMode::IN_FLIGHT);
                _readyToLaunch = false;
            }
            else
            {
                char buf[64];
                snprintf(buf, sizeof(buf), "FSM: Магнит убран (удержание %ums), пуск не взведен\n", duration);
                Registry::getLogger().info(buf);
            }
        }

        /**
         * @brief Вспомогательный метод для смены состояния и уведомления шины.
         */
        auto changeState(BaseFlightState *newState, FlightMode mode) -> void
        {
            _fsm.transitionTo(newState);
            _currentMode = mode;
            _bus->publish(FlightStateEvent::ID, FlightStateEvent(mode));
        }

        EventBus<> *_bus;
        StateMachine _fsm;

        SetupState _setupState;
        ArmedState _armedState;
        InFlightState _inFlightState;

        FlightMode _currentMode = FlightMode::SETUP;
        bool _readyToLaunch = false;
    };
}

#endif