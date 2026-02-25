#ifndef APPLICATION_FLIGHT_STATES_ARMED_H
#define APPLICATION_FLIGHT_STATES_ARMED_H

#include "BaseFlightState.h"

namespace application::flight
{
    class InFlightState;

    class ArmedState : public BaseFlightState
    {
    public:
        void setInFlightState(BaseFlightState *state) { _inFlightState = state; }

        [[nodiscard]] auto getName() const -> const char * override { return "ARMED"; }
        [[nodiscard]] auto isConfigLocked() const -> bool override { return true; }

        auto onEnter() -> void override
        {
            core2::Registry::getLogger().info("MODE: Вход в режим ОЖИДАНИЯ (Конфиг заблокирован)\n");
            _readyToLaunch = false;
        }

        auto handleGesture(application::events::HallGesture gesture) -> BaseFlightState * override
        {
            if (gesture == application::events::HallGesture::LONG_PRESS_START)
            {
                _readyToLaunch = true;
                core2::Registry::getLogger().info("FSM: ПУСК ГОТОВ\n");
            }
            else if (gesture == application::events::HallGesture::RELEASE && _readyToLaunch)
            {
                return _inFlightState;
            }
            return nullptr;
        }

    private:
        BaseFlightState *_inFlightState = nullptr;
        bool _readyToLaunch = false;
    };
}

#endif