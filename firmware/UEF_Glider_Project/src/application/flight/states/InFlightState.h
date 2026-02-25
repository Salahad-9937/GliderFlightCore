#ifndef APPLICATION_FLIGHT_STATES_IN_FLIGHT_H
#define APPLICATION_FLIGHT_STATES_IN_FLIGHT_H

#include "BaseFlightState.h"
#include "../../../core2/hal/INetwork.h"
#include <ESP8266WiFi.h>

namespace application::flight
{
    class InFlightState : public BaseFlightState
    {
    public:
        explicit InFlightState(core2::hal::INetwork &net) : _net(&net) {}

        [[nodiscard]] auto getName() const -> const char * override { return "FLIGHT"; }
        [[nodiscard]] auto isConfigLocked() const -> bool override { return true; }

        auto onEnter() -> void override
        {
            core2::Registry::getLogger().info("MODE: Взлет! Отключение Wi-Fi...\n");
            _net->setPower(false);
        }

        auto onExit() -> void override
        {
            core2::Registry::getLogger().info("MODE: Посадка. Восстановление Wi-Fi...\n");
            _net->setPower(true);
            // Принудительно устанавливаем режим, так как setPower(true) только будит радио
            WiFi.mode(WIFI_AP);
        }

    private:
        core2::hal::INetwork *_net;
    };
}

#endif