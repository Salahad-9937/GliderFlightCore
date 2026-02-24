#ifndef CORE2_ILOGGER_H
#define CORE2_ILOGGER_H

namespace core2
{

    /**
     * Интерфейс логгера (Инверсия зависимостей, п. 5.5 Протокола).
     */
    class ILogger
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~ILogger() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        // Интерфейсы не должны копироваться или перемещаться, чтобы избежать срезки объектов (Slicing)
        ILogger() = default;
        ILogger(const ILogger &) = delete;
        auto operator=(const ILogger &) -> ILogger & = delete;
        ILogger(ILogger &&) = delete;
        auto operator=(ILogger &&) -> ILogger & = delete;

        virtual void info(const char *msg) = 0;
        virtual void error(const char *msg) = 0;
        virtual void debug(const char *msg) = 0;
    };

} // namespace core2

#endif