#ifndef CORE2_REGISTRY_H
#define CORE2_REGISTRY_H

#include "ILogger.h"
#include "../hal/ILock.h"

namespace core2
{
    /**
     * @brief Глобальный реестр сервисов (Service Locator).
     */
    class Registry
    {
    public:
        // --- Logger ---
        static auto injectLogger(ILogger *logger) -> void { _logger = logger; }

        static auto getLogger() -> ILogger &
        {
            static NullLogger nullLogger;
            return (_logger != nullptr) ? *_logger : nullLogger;
        }

        // --- Lock (Критическая секция) ---
        static auto injectLock(hal::ILock *lock) -> void { _lock = lock; }

        static auto getLock() -> hal::ILock &
        {
            static NullLock nullLock;
            return (_lock != nullptr) ? *_lock : nullLock;
        }

    private:
        static ILogger *_logger;
        static hal::ILock *_lock;

        class NullLogger : public ILogger
        {
        public:
            auto info(const char *msg) -> void override { (void)msg; }
            auto error(const char *msg) -> void override { (void)msg; }
            auto debug(const char *msg) -> void override { (void)msg; }
        };

        class NullLock : public hal::ILock
        {
        public:
            auto lock() -> void override {}
            auto unlock() -> void override {}
        };
    };
} // namespace core2

#endif