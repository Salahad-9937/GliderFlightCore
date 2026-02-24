#ifndef CORE2_EVENT_BUS_H
#define CORE2_EVENT_BUS_H

#include "EventListener.h"
#include "../base/Registry.h"
#include "../base/Result.h"
#include "../Config.h"
#include "../utils/ScopedLock.h"
#include <array>

namespace core2
{

    /**
     * Шина событий с защитой от рекурсии и потокобезопасностью.
     */
    template <
        size_t MAX_LISTENERS = config::MAX_LISTENERS,
        size_t MAX_RECURSION = config::MAX_EVENT_RECURSION>
    class EventBus
    {
    public:
        EventBus() = default;

        auto subscribe(IEventListener *listener) -> Status
        {
            // Защита доступа к массиву подписчиков
            utils::ScopedLock guard(Registry::getLock());

            if (_listenersCount >= MAX_LISTENERS)
            {
                Registry::getLogger().error("EventBus: Достигнут лимит подписчиков!");
                return Status::fail(ErrorCode::OUT_OF_MEMORY);
            }

            // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
            _listeners[_listenersCount] = listener;
            _listenersCount++;
            return Status::ok();
        }

        // Исправлено: readability-identifier-length (id -> eventId)
        auto publish(EventID eventId, const event::Base &data) -> void
        {
            // Защита процесса рассылки
            utils::ScopedLock guard(Registry::getLock());

            if (_recursionDepth >= MAX_RECURSION)
            {
                Registry::getLogger().error("EventBus: КРИТИЧЕСКАЯ ОШИБКА! Превышен лимит рекурсии.");
                return;
            }

            _recursionDepth++;
            for (size_t i = 0; i < _listenersCount; i++)
            {
                // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
                if (_listeners[i] != nullptr)
                {
                    // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
                    _listeners[i]->onEvent(eventId, data);
                }
            }
            _recursionDepth--;
        }

    private:
        // Исправлено: cppcoreguidelines-avoid-c-arrays и cppcoreguidelines-pro-type-member-init
        std::array<IEventListener *, MAX_LISTENERS> _listeners{};

        // Исправлено: cppcoreguidelines-use-default-member-init
        size_t _listenersCount{0};
        uint8_t _recursionDepth{0};
    };

} // namespace core2

#endif