#ifndef CORE2_ITIMER_H
#define CORE2_ITIMER_H

#include "../base/Time.h"

namespace core2::hal
{

    /**
     * Интерфейс системного таймера.
     */
    class ITimer
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~ITimer() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        ITimer() = default;
        ITimer(const ITimer &) = delete;
        auto operator=(const ITimer &) -> ITimer & = delete;
        ITimer(ITimer &&) = delete;
        auto operator=(ITimer &&) -> ITimer & = delete;

        virtual auto now() -> Timestamp = 0;
        virtual auto delay(Duration duration) -> void = 0;
    };

} // namespace core2::hal

#endif