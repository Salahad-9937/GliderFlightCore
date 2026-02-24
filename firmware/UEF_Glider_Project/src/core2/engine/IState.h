#ifndef CORE2_ISTATE_H
#define CORE2_ISTATE_H

#include <stdint.h>

namespace core2
{

    /**
     * Интерфейс состояния (п. 1.2 Протокола - Полиморфизм вместо Switch).
     */
    class IState
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~IState() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        // Интерфейсы не должны копироваться или перемещаться
        IState() = default;
        IState(const IState &) = delete;
        auto operator=(const IState &) -> IState & = delete;
        IState(IState &&) = delete;
        auto operator=(IState &&) -> IState & = delete;

        // Вызывается один раз при переходе в это состояние
        virtual auto onEnter() -> void = 0;

        // Вызывается в каждом цикле loop
        virtual auto onUpdate(uint32_t now) -> void = 0;

        // Вызывается перед выходом из состояния
        virtual auto onExit() -> void = 0;

        // Уникальное имя для отладки
        // Исправлено: modernize-use-nodiscard и modernize-use-trailing-return-type
        [[nodiscard]] virtual auto getName() const -> const char * = 0;
    };

} // namespace core2

#endif