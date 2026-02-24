#ifndef INFRASTRUCTURE_PERSISTENCE_STORAGE_KEYS_H
#define INFRASTRUCTURE_PERSISTENCE_STORAGE_KEYS_H

#include <stdint.h>

namespace infrastructure::persistence
{
    /**
     * Константы ключей для IStorage.
     * Позволяют избежать магических чисел при обращении к файлам.
     */
    enum class StorageKey : uint16_t
    {
        CALIBRATION = 100,   ///< Данные калибровки датчиков
        HARDWARE_PINS = 101, ///< Конфигурация пинов (если меняется динамически)
        FLIGHT_PROGRAM = 200 ///< Текущая активная программа полета
    };
}

#endif