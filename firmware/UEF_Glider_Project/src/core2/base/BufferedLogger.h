#ifndef CORE2_BUFFERED_LOGGER_H
#define CORE2_BUFFERED_LOGGER_H

#include "ILogger.h"
#include "../utils/CircularBuffer.h"
#include "../Config.h"
#include <array>

namespace core2
{

    /**
     * Неблокирующий логгер (Проблема №2 - Blocking I/O).
     * Складывает сообщения в промежуточный буфер в RAM.
     */
    class BufferedLogger : public ILogger
    {
    public:
        static constexpr size_t DEFAULT_FLUSH_BYTES = 32;

        BufferedLogger() = default;

        auto info(const char *msg) -> void override
        {
            pushStr("[I] ");
            pushStr(msg);
        }
        auto error(const char *msg) -> void override
        {
            pushStr("[E] ");
            pushStr(msg);
        }
        auto debug(const char *msg) -> void override
        {
            pushStr("[D] ");
            pushStr(msg);
        }

        /**
         * Сброс буфера в реальное железо.
         * Должен вызываться планировщиком в свободное время.
         * @param hwLogger Реальный логгер (например, Serial)
         * @param maxBytes Лимит байт за один проход (чтобы не блокировать цикл долго)
         */
        // NOLINTNEXTLINE(readability-convert-member-functions-to-static)
        auto flush(ILogger &hwLogger, size_t maxBytes = DEFAULT_FLUSH_BYTES) -> void
        {
            constexpr size_t CHUNK_SIZE = 32;
            constexpr size_t BUFFER_SIZE = CHUNK_SIZE + 1; // +1 для null-terminator

            std::array<char, BUFFER_SIZE> chunk{};
            size_t processed = 0;

            while (processed < maxBytes && !_buffer.isEmpty())
            {
                uint8_t byteVal = 0;
                if (_buffer.pop(byteVal))
                {
                    // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
                    chunk[processed % CHUNK_SIZE] = static_cast<char>(byteVal);
                    processed++;

                    // Если набрали пачку или буфер пуст - выводим
                    if (processed % CHUNK_SIZE == 0 || _buffer.isEmpty())
                    {
                        size_t len = processed % CHUNK_SIZE;
                        if (len == 0)
                        {
                            len = CHUNK_SIZE;
                        }
                        // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
                        chunk[len] = '\0';
                        // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-array-to-pointer-decay)
                        hwLogger.info(chunk.data()); // Используем info как низкоуровневый вывод
                    }
                }
            }
        }

        [[nodiscard]] auto getFillLevel() const -> size_t { return _buffer.count(); }

    private:
        utils::CircularBuffer<config::LOG_BUFFER_SIZE> _buffer;

        // NOLINTNEXTLINE(readability-convert-member-functions-to-static)
        auto pushStr(const char *str) -> void
        {
            while (*str != '\0')
            {
                // Если буфер полон, мы просто перестаем писать (Safety First)
                if (!_buffer.push(static_cast<uint8_t>(*str)))
                {
                    break;
                }
                str++; // NOLINT(cppcoreguidelines-pro-bounds-pointer-arithmetic)
            }
        }
    };

} // namespace core2

#endif