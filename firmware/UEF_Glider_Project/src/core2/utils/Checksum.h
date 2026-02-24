#ifndef CORE2_CHECKSUM_H
#define CORE2_CHECKSUM_H

#include <stdint.h>
#include <stddef.h>

namespace core2::utils
{

    /**
     * Утилита для расчета контрольных сумм (п. 10.1 Протокола).
     * Используется для проверки целостности данных в IStorage.
     */
    class Checksum
    {
    public:
        /**
         * Простой и быстрый алгоритм CRC16-CCITT.
         */
        static auto crc16(const uint8_t *data, size_t length) -> uint16_t
        {
            uint16_t crc = 0xFFFF;
            for (size_t i = 0; i < length; i++)
            {
                // Исправлено: cppcoreguidelines-pro-bounds-pointer-arithmetic
                // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-pointer-arithmetic)
                crc ^= static_cast<uint16_t>(data[i]) << 8;
                for (int j = 0; j < 8; j++)
                {
                    // Исправлено: readability-implicit-bool-conversion
                    if ((crc & 0x8000) != 0)
                    {
                        crc = (crc << 1) ^ 0x1021;
                    }
                    else
                    {
                        crc <<= 1;
                    }
                }
            }
            return crc;
        }
    };

} // namespace core2::utils

#endif