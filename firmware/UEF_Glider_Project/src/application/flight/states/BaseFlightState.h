#ifndef APPLICATION_FLIGHT_STATES_BASE_H
#define APPLICATION_FLIGHT_STATES_BASE_H

#include "../../../core2/engine/IState.h"
#include "../../../core2/base/Registry.h"

namespace application::flight
{
    /**
     * @brief Абстрактный базовый класс для всех состояний полета.
     */
    class BaseFlightState : public core2::IState
    {
    public:
        auto onEnter() -> void override {}
        auto onUpdate(uint32_t now) -> void override { (void)now; }
        auto onExit() -> void override {}

        /**
         * @brief Проверка, разрешено ли изменение конфигурации в этом состоянии.
         */
        [[nodiscard]] virtual auto isConfigLocked() const -> bool = 0;
    };
}

#endif