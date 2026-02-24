#ifndef CORE2_EVENT_H
#define CORE2_EVENT_H

#include <stdint.h>

namespace core2
{

    // Исправлено: modernize-use-using
    using EventID = uint16_t;

    namespace event
    {

        /**
         * Базовая структура-маркер для всех событий.
         */
        struct Base
        {
            // Исправлено: modernize-use-equals-default
            virtual ~Base() = default;

            // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
            // Интерфейсы не должны копироваться или перемещаться
            Base() = default;
            Base(const Base &) = delete;
            auto operator=(const Base &) -> Base & = delete;
            Base(Base &&) = delete;
            auto operator=(Base &&) -> Base & = delete;
        };

    } // namespace event
} // namespace core2

#endif