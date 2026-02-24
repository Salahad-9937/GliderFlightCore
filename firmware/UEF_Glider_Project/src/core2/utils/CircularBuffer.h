#ifndef CORE2_CIRCULAR_BUFFER_H
#define CORE2_CIRCULAR_BUFFER_H

#include <stdint.h>
#include <stddef.h>
#include <array>

namespace core2::utils
{

    /**
     * Кольцевой буфер для хранения байт (п. 14.4 Протокола - Управление памятью).
     * Работает без динамической аллокации.
     */
    template <size_t SIZE>
    class CircularBuffer
    {
    public:
        CircularBuffer() = default;

        auto push(uint8_t value) -> bool
        {
            if (isFull())
            {
                return false;
            }

            // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
            _data[_head] = value;
            _head = (_head + 1) % SIZE;
            _count++;
            return true;
        }

        auto pop(uint8_t &value) -> bool
        {
            if (isEmpty())
            {
                return false;
            }

            // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
            value = _data[_tail];
            _tail = (_tail + 1) % SIZE;
            _count--;
            return true;
        }

        [[nodiscard]] auto isEmpty() const -> bool { return _count == 0; }
        [[nodiscard]] auto isFull() const -> bool { return _count == SIZE; }
        [[nodiscard]] auto count() const -> size_t { return _count; }
        [[nodiscard]] auto capacity() const -> size_t { return SIZE; }

    private:
        // Исправлено: cppcoreguidelines-avoid-c-arrays и cppcoreguidelines-pro-type-member-init
        std::array<uint8_t, SIZE> _data{};

        // Исправлено: cppcoreguidelines-use-default-member-init
        size_t _head{0};
        size_t _tail{0};
        size_t _count{0};
    };

} // namespace core2::utils

#endif