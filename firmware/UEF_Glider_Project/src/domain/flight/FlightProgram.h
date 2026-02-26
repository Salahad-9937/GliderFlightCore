#ifndef DOMAIN_FLIGHT_FLIGHT_PROGRAM_H
#define DOMAIN_FLIGHT_FLIGHT_PROGRAM_H

#include "../../core2/engine/Sequencer.h"
#include <stdint.h>
#include <string.h>
#include <array>

namespace domain::flight
{
    /**
     * @brief Лимиты программы полета.
     */
    enum class ProgramLimits : uint8_t
    {
        MAX_STEPS = 16,    ///< Максимальное кол-во фаз полета
        NAME_MAX_LEN = 32, ///< Макс. длина имени программы
        ID_MAX_LEN = 37    ///< Длина UUID строки + null
    };

    /**
     * @brief Доменная модель полетной программы (Rich Domain Model).
     */
    struct FlightProgram
    {
        std::array<char, static_cast<size_t>(ProgramLimits::ID_MAX_LEN)> id{};
        std::array<char, static_cast<size_t>(ProgramLimits::NAME_MAX_LEN)> name{};
        uint8_t stepsCount = 0;
        std::array<core2::SequenceStep, static_cast<size_t>(ProgramLimits::MAX_STEPS)> steps{};

        FlightProgram() = default;

        /**
         * @brief Проверка валидности программы.
         */
        [[nodiscard]] auto isValid() const -> bool
        {
            if (stepsCount == 0 || stepsCount > static_cast<uint8_t>(ProgramLimits::MAX_STEPS))
            {
                return false;
            }
            if (id.at(0) == '\0')
            {
                return false;
            }

            for (uint8_t i = 0; i < stepsCount; i++)
            {
                if (steps.at(i).durationMs == 0)
                {
                    return false;
                }
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
                total += steps.at(i).durationMs;
            }
            return total;
        }

        /**
         * @brief Глубокое сравнение программ.
         * Проверяет ID, имя, количество шагов и параметры каждого шага.
         */
        [[nodiscard]] auto isSameAs(const FlightProgram &other) const -> bool
        {
            // 1. Сравнение ID
            if (strcmp(id.data(), other.id.data()) != 0)
            {
                return false;
            }

            // 2. Сравнение имени
            if (strcmp(name.data(), other.name.data()) != 0)
            {
                return false;
            }

            // 3. Сравнение количества шагов
            if (stepsCount != other.stepsCount)
            {
                return false;
            }

            // 4. Пошаговое сравнение данных секвенсора
            for (uint8_t i = 0; i < stepsCount; i++)
            {
                if (steps.at(i).value != other.steps.at(i).value ||
                    steps.at(i).durationMs != other.steps.at(i).durationMs)
                {
                    return false;
                }
            }

            return true;
        }
    };
}

#endif