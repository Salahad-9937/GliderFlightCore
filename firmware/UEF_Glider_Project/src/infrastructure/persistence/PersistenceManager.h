#ifndef INFRASTRUCTURE_PERSISTENCE_MANAGER_H
#define INFRASTRUCTURE_PERSISTENCE_MANAGER_H

#include "../../core2/hal/IStorage.h"
#include "../../core2/utils/Checksum.h"
#include "../../core2/base/Registry.h"
#include "StorageKeys.h"

namespace infrastructure::persistence
{
    using namespace core2;

    /**
     * Высокоуровневый менеджер для работы с данными.
     * Добавляет заголовок с CRC16 для защиты от повреждения файлов (п. 10.1 Протокола).
     */
    class PersistenceManager
    {
    public:
        explicit PersistenceManager(hal::IStorage &storage) : _storage(&storage) {}

        /**
         * Сохраняет структуру данных с расчетом контрольной суммы.
         */
        template <typename T>
        auto save(StorageKey key, const T &data) -> Status
        {
            StorageRecord<T> record;
            record.payload = data;
            record.crc = utils::Checksum::crc16(reinterpret_cast<const uint8_t *>(&record.payload), sizeof(T));

            return _storage->store(static_cast<uint16_t>(key), &record, sizeof(record));
        }

        /**
         * Загружает структуру данных и проверяет её целостность.
         */
        template <typename T>
        auto load(StorageKey key, T &buffer) -> Status
        {
            StorageRecord<T> record;
            auto status = _storage->load(static_cast<uint16_t>(key), &record, sizeof(record));

            if (!status.isOk())
                return status;

            uint16_t calculatedCrc = utils::Checksum::crc16(reinterpret_cast<const uint8_t *>(&record.payload), sizeof(T));

            if (calculatedCrc != record.crc)
            {
                Registry::getLogger().error("PERSISTENCE: Ошибка CRC! Данные повреждены.\n");
                return ErrorCode::INVALID_ARGUMENT;
            }

            buffer = record.payload;
            return Status::ok();
        }

    private:
        /**
         * Внутренний контейнер для хранения данных с CRC.
         */
        template <typename Payload>
        struct StorageRecord
        {
            Payload payload;
            uint16_t crc;
        };

        hal::IStorage *_storage;
    };
}

#endif