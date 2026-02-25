#ifndef APPLICATION_FLIGHT_STATES_SETUP_H
#define APPLICATION_FLIGHT_STATES_SETUP_H

#include "BaseFlightState.h"

namespace application::flight
{
    // Предварительное объявление для разрешения циклической зависимости
    class ArmedState;

    class SetupState : public BaseFlightState
    {
    public:
        void setArmedState(BaseFlightState *state) { _armedState = state; }

        [[nodiscard]] auto getName() const -> const char * override { return "SETUP"; }
        [[nodiscard]] auto isConfigLocked() const -> bool override { return false; }

        auto onEnter() -> void override
        {
            core2::Registry::getLogger().info("MODE: Вход в режим НАСТРОЙКИ (Доступ разрешен)\n");
        }

        auto handleGesture(application::events::HallGesture gesture) -> BaseFlightState * override
        {
            if (gesture == application::events::HallGesture::LONG_PRESS_START)
            {
                return _armedState;
            }
            return nullptr;
        }

    private:
        BaseFlightState *_armedState = nullptr;
    };
}

#endif