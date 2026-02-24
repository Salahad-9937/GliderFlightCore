#ifndef CORE2_IWATCHDOG_H
#define CORE2_IWATCHDOG_H

#include "../base/Result.h"

namespace core2::hal
{

    /**
     * Аппаратный Watchdog (WDT).
     * Если цикл loop() зависнет, планер должен перезагрузиться.
     */
    class IWatchdog
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~IWatchdog() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        IWatchdog() = default;
        IWatchdog(const IWatchdog &) = delete;
        auto operator=(const IWatchdog &) -> IWatchdog & = delete;
        IWatchdog(IWatchdog &&) = delete;
        auto operator=(IWatchdog &&) -> IWatchdog & = delete;

        /**
         * Инициализация с таймаутом (мс).
         */
        virtual auto begin(uint32_t timeoutMs) -> Status = 0;

        /**
         * Сброс таймера ("кормление" собаки).
         */
        // Исправлено: modernize-use-trailing-return-type
        virtual auto kick() -> void = 0;
    };

} // namespace core2::hal
#endif