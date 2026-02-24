#ifndef CORE2_ILOCK_H
#define CORE2_ILOCK_H

namespace core2::hal
{

    /**
     * Интерфейс критической секции (п. 10.1 Протокола - Защита периметра).
     * Обеспечивает атомарность операций в многопоточной или прерываемой среде.
     */
    class ILock
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~ILock() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        ILock() = default;
        ILock(const ILock &) = delete;
        auto operator=(const ILock &) -> ILock & = delete;
        ILock(ILock &&) = delete;
        auto operator=(ILock &&) -> ILock & = delete;

        virtual void lock() = 0;
        virtual void unlock() = 0;
    };

} // namespace core2::hal

#endif