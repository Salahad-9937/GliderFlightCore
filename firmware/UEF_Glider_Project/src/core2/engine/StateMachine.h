#ifndef CORE2_STATE_MACHINE_H
#define CORE2_STATE_MACHINE_H

#include "IState.h"
#include "../base/ILogger.h"
#include <stdint.h>

namespace core2
{

    /**
     * Движок состояний (Infrastructure Layer).
     * Управляет жизненным циклом без прямой зависимости от бизнес-логики.
     */
    class StateMachine
    {
    public:
        // Исправлено: внедрение зависимости через указатель (avoid-const-or-ref-data-members)
        explicit StateMachine(ILogger &logger) : _logger(&logger) {}

        /**
         * Безопасный переход в новое состояние.
         */
        auto transitionTo(IState *newState) -> void
        {
            // Исправлено: явное сравнение с nullptr (implicit-bool-conversion)
            if (newState == nullptr)
            {
                _logger->error("FSM: Попытка перехода в NULL состояние!");
                return;
            }

            if (newState == _currentState)
            {
                return;
            }

            if (_currentState != nullptr)
            {
                _logger->debug("Выход из состояния...");
                _currentState->onExit();
            }

            _currentState = newState;

            _logger->info("FSM: State -> ");
            _logger->info(_currentState->getName());

            _currentState->onEnter();
        }

        /**
         * Обновление текущего состояния.
         */
        auto update(uint32_t now) -> void
        {
            if (_currentState != nullptr)
            {
                _currentState->onUpdate(now);
            }
        }

        // Исправлено: [[nodiscard]] и trailing return type
        [[nodiscard]] auto getCurrentState() const -> IState * { return _currentState; }

    private:
        // Исправлено: использование указателя вместо ссылки и инициализация при объявлении
        ILogger *_logger{nullptr};
        IState *_currentState{nullptr};
    };

} // namespace core2

#endif