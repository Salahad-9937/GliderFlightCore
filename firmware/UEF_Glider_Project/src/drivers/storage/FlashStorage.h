#ifndef FLASH_STORAGE_H
#define FLASH_STORAGE_H

#include <LittleFS.h>
#include "../../core2/hal/IStorage.h"

namespace drivers
{
    class FlashStorage : public core2::hal::IStorage
    {
    public:
        auto store(uint16_t key, const void *data, size_t size) -> core2::Status override
        {
            char path[16];
            snprintf(path, sizeof(path), "/f_%u.bin", key);
            File f = LittleFS.open(path, "w");
            if (!f)
            {
                return core2::Status::fail(core2::ErrorCode::HARDWARE_FAILURE);
            }
            f.write((const uint8_t *)data, size);
            f.close();
            return core2::Status::ok();
        }

        auto append(uint16_t key, const void *data, size_t size) -> core2::Status override
        {
            char path[16];
            snprintf(path, sizeof(path), "/f_%u.bin", key);
            // Режим "a" открывает файл для дозаписи в конец
            File f = LittleFS.open(path, "a");
            if (!f)
            {
                return core2::Status::fail(core2::ErrorCode::HARDWARE_FAILURE);
            }
            f.write((const uint8_t *)data, size);
            f.close();
            return core2::Status::ok();
        }

        auto load(uint16_t key, void *buffer, size_t size) -> core2::Status override
        {
            char path[16];
            snprintf(path, sizeof(path), "/f_%u.bin", key);
            if (!LittleFS.exists(path))
            {
                return core2::Status::fail(core2::ErrorCode::NOT_FOUND);
            }
            File f = LittleFS.open(path, "r");
            if (!f)
            {
                return core2::Status::fail(core2::ErrorCode::HARDWARE_FAILURE);
            }
            f.read((uint8_t *)buffer, size);
            f.close();
            return core2::Status::ok();
        }
    };
}
#endif