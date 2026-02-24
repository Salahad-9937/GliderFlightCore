#ifndef CORE2_EVENT_LISTENER_H
#define CORE2_EVENT_LISTENER_H

#include "Event.h"

namespace core2
{

    /**
     * Внутренний, нетипизированный интерфейс.
     * Пользователи не должны его использовать напрямую.
     */
    class IEventListener
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~IEventListener() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        IEventListener() = default;
        IEventListener(const IEventListener &) = delete;
        auto operator=(const IEventListener &) -> IEventListener & = delete;
        IEventListener(IEventListener &&) = delete;
        auto operator=(IEventListener &&) -> IEventListener & = delete;

        // Исправлено: readability-identifier-length (id -> eventId)
        virtual void onEvent(EventID eventId, const event::Base &event) = 0;
    };

    /**
     * Типобезопасный интерфейс слушателя.
     * @tparam T Тип структуры события, на которое идет подписка.
     */
    template <typename T>
    class TypedEventListener : public IEventListener
    {
    public:
        // Исправлено: cppcoreguidelines-explicit-virtual-functions (redundant override with final)
        // Исправлено: readability-identifier-length (id -> eventId)
        void onEvent(EventID eventId, const event::Base &event) final
        {
            // Проверяем, что ID события соответствует типу, который мы ждем.
            // T::ID - это статический ID, который будет в каждой структуре события.
            if (eventId == T::ID)
            {
                onTypedEvent(static_cast<const T &>(event));
            }
        }

        /**
         * Этот метод реализует конечный пользователь.
         */
        virtual void onTypedEvent(const T &event) = 0;
    };

} // namespace core2

#endif