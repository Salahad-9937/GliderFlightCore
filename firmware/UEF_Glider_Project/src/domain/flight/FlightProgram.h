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
     * @brief Доменная модель полетной программы (Rich Domain Model).
     * Содержит не только данные, но и логику их обработки.
     */
    struct FlightProgram
    {
        char id[ID_MAX_LEN];                  ///< Уникальный идентификатор
        char name[NAME_MAX_LEN];              ///< Имя программы
        uint8_t stepsCount;                   ///< Кол-во шагов
        core2::SequenceStep steps[MAX_STEPS]; ///< Массив шагов

        FlightProgram() : stepsCount(0)
        {
            memset(id, 0, ID_MAX_LEN);
            memset(name, 0, NAME_MAX_LEN);
            memset(steps, 0, sizeof(steps));
        }

        /**
         * @brief Проверка валидности программы.
         */
        [[nodiscard]] auto isValid() const -> bool
        {
            if (stepsCount == 0 || stepsCount > MAX_STEPS)
                return false;
            if (id[0] == '\0')
                return false;

            // Проверка на наличие шагов с нулевой длительностью
            for (uint8_t i = 0; i < stepsCount; i++)
            {
                if (steps[i].durationMs == 0)
                    return false;
            }
            return true;
        }

        /**
         * @brief Расчет общей длительности программы.
         */
        [[nodiscard]] auto getTotalDuration() const -> uint32_t
        {
            uint32_t total = 0;
            for (uint8_t i = 0; i < stepsCount; i++)
            {
                total += steps[i].durationMs;
            }
            return total;
        }

        /**
         * @brief Сравнение программ по ID.
         */
        auto isSameAs(const FlightProgram &other) const -> bool
        {
            return strcmp(id, other.id) == 0;
        }
    };
}

#endif