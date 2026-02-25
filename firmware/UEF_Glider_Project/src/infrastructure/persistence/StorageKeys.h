#ifndef INFRASTRUCTURE_PERSISTENCE_STORAGE_KEYS_H
#define INFRASTRUCTURE_PERSISTENCE_STORAGE_KEYS_H

#include <stdint.h>

namespace infrastructure::persistence
{
    /**
     * @brief Константы ключей для IStorage.
     * Каждому ключу соответствует отдельный файл в LittleFS.
     */
    // Исправлено: performance-enum-size (использование uint8_t вместо uint16_t)
    enum class StorageKey : uint8_t
    {
        CALIBRATION = 100,    ///< Данные калибровки датчиков (f_100.bin)
        HARDWARE_PINS = 101,  ///< Конфигурация пинов (f_101.bin)
        FLIGHT_PROGRAM = 200, ///< Активная программа полета (f_200.bin)
        FLIGHT_LOG = 255      ///< Лог сырого давления полета (f_255.bin)
    };
}

#endif