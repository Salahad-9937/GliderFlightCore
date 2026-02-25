#ifndef APPLICATION_FLIGHT_STATES_ARMED_H
#define APPLICATION_FLIGHT_STATES_ARMED_H

#include "BaseFlightState.h"

namespace application::flight
{
    class ArmedState : public BaseFlightState
    {
    public:
        [[nodiscard]] auto getName() const -> const char * override { return "ARMED"; }
        [[nodiscard]] auto isConfigLocked() const -> bool override { return true; }

        auto onEnter() -> void override
        {
            core2::Registry::getLogger().info("MODE: Вход в режим ОЖИДАНИЯ (Конфиг заблокирован)\n");
        }
    };
}

#endif