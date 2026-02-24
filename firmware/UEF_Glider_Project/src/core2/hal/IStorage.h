#ifndef CORE2_ISTORAGE_H
#define CORE2_ISTORAGE_H

#include "../base/Result.h"
#include <stddef.h>
#include <stdint.h>

namespace core2::hal
{

    /**
     * Интерфейс абстрактного хранилища (п. 7.1 Протокола).
     * Позволяет ядру сохранять структуры (Value Objects) без знаний о LittleFS/EEPROM.
     */
    class IStorage
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~IStorage() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        IStorage() = default;
        IStorage(const IStorage &) = delete;
        auto operator=(const IStorage &) -> IStorage & = delete;
        IStorage(IStorage &&) = delete;
        auto operator=(IStorage &&) -> IStorage & = delete;

        /**
         * Сохранить блок данных (Перезапись файла).
         * @param key Уникальный ID записи (хеш или индекс)
         */
        virtual auto store(uint16_t key, const void *data, size_t size) -> Status = 0;

        /**
         * Дописать данные в конец существующей записи.
         * Если записи нет, она будет создана.
         */
        virtual auto append(uint16_t key, const void *data, size_t size) -> Status = 0;

        /**
         * Загрузить блок данных.
         */
        virtual auto load(uint16_t key, void *buffer, size_t size) -> Status = 0;
    };

} // namespace core2::hal

#endif