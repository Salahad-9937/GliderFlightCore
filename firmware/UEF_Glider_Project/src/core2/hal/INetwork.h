#ifndef CORE2_INETWORK_H
#define CORE2_INETWORK_H

#include "../base/Result.h"

namespace core2::hal
{

    /**
     * Интерфейс управления радиомодулем.
     * Прямое требование проекта: "Wi-Fi OFF в режиме Flight".
     */
    class INetwork
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~INetwork() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        INetwork() = default;
        INetwork(const INetwork &) = delete;
        auto operator=(const INetwork &) -> INetwork & = delete;
        INetwork(INetwork &&) = delete;
        auto operator=(INetwork &&) -> INetwork & = delete;

        // Включение/выключение питания радиомодуля (Wi-Fi/BT)
        // Исправлено: readability-identifier-length (on -> enable)
        virtual auto setPower(bool enable) -> Status = 0;

        // Проверка, активно ли радио в данный момент
        virtual auto isPowered() -> bool = 0;
    };

} // namespace core2::hal
#endif