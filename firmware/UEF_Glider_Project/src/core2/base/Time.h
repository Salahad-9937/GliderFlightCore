#ifndef CORE2_TIME_H
#define CORE2_TIME_H

#include <stdint.h>

namespace core2
{

    /**
     * Типизированное время (устранение Primitive Obsession, п. 5 Протокола).
     */
    // Исправлено: modernize-use-using
    using milliseconds = uint32_t;

    class Duration
    {
    public:
        static constexpr milliseconds MS_PER_SEC = 1000;

        // Исправлено: readability-identifier-length
        explicit Duration(milliseconds msValue) : _ms(msValue) {}

        // Исправлено: nodiscard и trailing return type
        [[nodiscard]] auto toMs() const -> milliseconds { return _ms; }

        static auto fromSeconds(float sec) -> Duration
        {
            return Duration(static_cast<milliseconds>(sec * static_cast<float>(MS_PER_SEC)));
        }

    private:
        milliseconds _ms;
    };

    class Timestamp
    {
    public:
        // Исправлено: readability-identifier-length
        explicit Timestamp(milliseconds msValue) : _ms(msValue) {}

        // Исправлено: nodiscard и trailing return type
        [[nodiscard]] auto ticks() const -> milliseconds { return _ms; }

        [[nodiscard]] auto hasPassed(Timestamp now, Duration timeout) const -> bool
        {
            return (now.ticks() - _ms) >= timeout.toMs();
        }

    private:
        milliseconds _ms;
    };

} // namespace core2

#endif