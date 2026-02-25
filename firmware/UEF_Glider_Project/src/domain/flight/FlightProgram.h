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
    // Исправлено: cppcoreguidelines-use-enum-class
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
        // Исправлено: cppcoreguidelines-avoid-c-arrays
        std::array<char, static_cast<size_t>(ProgramLimits::ID_MAX_LEN)> id{};
        std::array<char, static_cast<size_t>(ProgramLimits::NAME_MAX_LEN)> name{};
        uint8_t stepsCount = 0; // Исправлено: cppcoreguidelines-use-default-member-init
        std::array<core2::SequenceStep, static_cast<size_t>(ProgramLimits::MAX_STEPS)> steps{};

        // Исправлено: cppcoreguidelines-pro-type-member-init
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
            // Исправлено: cppcoreguidelines-pro-bounds-array-to-pointer-decay
            if (id.at(0) == '\0')
            {
                return false;
            }

            for (uint8_t i = 0; i < stepsCount; i++)
            {
                // Исправлено: cppcoreguidelines-pro-bounds-constant-array-index
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
                // Исправлено: cppcoreguidelines-pro-bounds-constant-array-index
                total += steps.at(i).durationMs;
            }
            return total;
        }

        /**
         * @brief Сравнение программ по ID.
         */
        // Исправлено: modernize-use-nodiscard
        [[nodiscard]] auto isSameAs(const FlightProgram &other) const -> bool
        {
            // Исправлено: cppcoreguidelines-pro-bounds-array-to-pointer-decay
            return strcmp(id.data(), other.id.data()) == 0;
        }
    };
}

#endif