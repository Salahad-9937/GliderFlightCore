#ifndef APPLICATION_FLIGHT_STATES_SETUP_H
#define APPLICATION_FLIGHT_STATES_SETUP_H

#include "BaseFlightState.h"

namespace application::flight
{
    class SetupState : public BaseFlightState
    {
    public:
        [[nodiscard]] auto getName() const -> const char * override { return "SETUP"; }
        [[nodiscard]] auto isConfigLocked() const -> bool override { return false; }

        auto onEnter() -> void override
        {
            core2::Registry::getLogger().info("MODE: Вход в режим НАСТРОЙКИ (Доступ разрешен)\n");
        }
    };
}

#endif