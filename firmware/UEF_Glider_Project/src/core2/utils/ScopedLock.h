#ifndef CORE2_SCOPED_LOCK_H
#define CORE2_SCOPED_LOCK_H

#include "../hal/ILock.h"

namespace core2::utils
{

    /**
     * RAII-обертка для автоматического управления блокировкой.
     * Исключает риск забытого unlock() при выходе из функции.
     */
    class ScopedLock
    {
    public:
        explicit ScopedLock(hal::ILock &lock) : _lock(lock)
        {
            _lock.lock();
        }

        ~ScopedLock()
        {
            _lock.unlock();
        }

        // Исправлено: cppcoreguidelines-special-member-functions и modernize-use-equals-delete
        // Удаленные функции должны быть публичными для лучших сообщений об ошибках.
        ScopedLock(const ScopedLock &) = delete;
        auto operator=(const ScopedLock &) -> ScopedLock & = delete;
        ScopedLock(ScopedLock &&) = delete;
        auto operator=(ScopedLock &&) -> ScopedLock & = delete;

    private:
        hal::ILock &_lock;
    };

} // namespace core2::utils

#endif