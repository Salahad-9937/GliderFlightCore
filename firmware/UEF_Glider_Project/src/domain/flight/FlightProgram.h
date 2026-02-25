#ifndef DOMAIN_FLIGHT_FLIGHT_PROGRAM_H
#define DOMAIN_FLIGHT_FLIGHT_PROGRAM_H

#include "../../core2/engine/Sequencer.h"
#include <stdint.h>
#include <string.h>

namespace domain::flight
{
    /**
     * @brief Лимиты программы полета.
     */
    enum ProgramLimits : uint8_t
    {
        MAX_STEPS = 16,    ///< Максимальное кол-во фаз полета
        NAME_MAX_LEN = 32, ///< Макс. длина имени программы
        ID_MAX_LEN = 37    ///< Длина UUID строки + null
    };

    /**
     * @brief Доменная модель полетной программы (Value Object).
     * Предназначена для хранения в бинарном виде с защитой CRC.
     */
    struct FlightProgram
    {
        char id[ID_MAX_LEN];                  ///< Уникальный идентификатор программы
        char name[NAME_MAX_LEN];              ///< Человекочитаемое имя
        uint8_t stepsCount;                   ///< Фактическое кол-во шагов
        core2::SequenceStep steps[MAX_STEPS]; ///< Массив шагов (значение, длительность)

        /**
         * @brief Конструктор по умолчанию с занулением данных.
         */
        FlightProgram() : stepsCount(0)
        {
            memset(id, 0, ID_MAX_LEN);
            memset(name, 0, NAME_MAX_LEN);
            memset(steps, 0, sizeof(steps));
        }

        /**
         * @brief Проверка валидности структуры.
         */
        [[nodiscard]] auto isValid() const -> bool
        {
            return (stepsCount > 0 && stepsCount <= MAX_STEPS && id[0] != '\0');
        }
    };
}

#endif