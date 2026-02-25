#ifndef APPLICATION_FLIGHT_STATES_BASE_H
#define APPLICATION_FLIGHT_STATES_BASE_H

#include "../../../core2/engine/IState.h"
#include "../../../core2/base/Registry.h"
#include "../../events/InputEvents.h"

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
         * @brief Обработка жеста в контексте текущего состояния.
         * @return Новое состояние или nullptr, если переход не требуется.
         */
        virtual auto handleGesture(application::events::HallGesture gesture) -> BaseFlightState * = 0;

        [[nodiscard]] virtual auto isConfigLocked() const -> bool = 0;
    };
}

#endif