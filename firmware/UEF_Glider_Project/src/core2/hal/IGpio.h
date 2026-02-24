#ifndef CORE2_IGPIO_H
#define CORE2_IGPIO_H

#include "../base/Result.h"

namespace core2::hal
{

    /**
     * Интерфейс цифрового выхода (Сервопривод, LED).
     */
    class IDigitalOutput
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~IDigitalOutput() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        IDigitalOutput() = default;
        IDigitalOutput(const IDigitalOutput &) = delete;
        auto operator=(const IDigitalOutput &) -> IDigitalOutput & = delete;
        IDigitalOutput(IDigitalOutput &&) = delete;
        auto operator=(IDigitalOutput &&) -> IDigitalOutput & = delete;

        virtual auto write(bool level) -> Status = 0;
    };

    /**
     * Интерфейс цифрового входа (Кнопка, Датчик Холла).
     */
    class IDigitalInput
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~IDigitalInput() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        IDigitalInput() = default;
        IDigitalInput(const IDigitalInput &) = delete;
        auto operator=(const IDigitalInput &) -> IDigitalInput & = delete;
        IDigitalInput(IDigitalInput &&) = delete;
        auto operator=(IDigitalInput &&) -> IDigitalInput & = delete;

        virtual auto read() -> Result<bool> = 0;
    };

} // namespace core2::hal

#endif