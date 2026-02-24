#ifndef CORE2_IACTUATOR_H
#define CORE2_IACTUATOR_H

#include "../base/Result.h"

// Исправлено: modernize-concat-nested-namespaces
namespace core2::hal
{

    /**
     * Универсальный интерфейс актуатора (Серво, Мотор, Диммер).
     * Принимает абстрактные единицы (напр. 0-180 для серво или 0-1000 для ШИМ).
     */
    class IActuator
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~IActuator() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        IActuator() = default;
        IActuator(const IActuator &) = delete;
        auto operator=(const IActuator &) -> IActuator & = delete;
        IActuator(IActuator &&) = delete;
        auto operator=(IActuator &&) -> IActuator & = delete;

        /**
         * Установить значение актуатора.
         */
        // Исправлено: modernize-use-trailing-return-type
        virtual auto setValue(int16_t value) -> Status = 0;
    };

} // namespace core2::hal

#endif