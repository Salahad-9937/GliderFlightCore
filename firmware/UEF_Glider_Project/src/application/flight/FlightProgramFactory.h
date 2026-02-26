#ifndef APPLICATION_FLIGHT_PROGRAM_FACTORY_H
#define APPLICATION_FLIGHT_PROGRAM_FACTORY_H

#include "../../domain/flight/FlightProgram.h"
#include "../../core2/base/Result.h"
#include <ArduinoJson.h>

namespace application::flight
{
    /**
     * @brief Фабрика для создания доменных моделей из внешних форматов.
     * Реализует новую логику: угол (angle) и задержка перед поворотом (delay).
     */
    class FlightProgramFactory
    {
    public:
        /**
         * @brief Создание программы из JSON-объекта.
         */
        static auto createFromJson(const JsonVariant &json) -> core2::Result<domain::flight::FlightProgram>
        {
            using namespace domain::flight;
            FlightProgram p;

            const char *idStr = json["id"] | "";
            const char *nameStr = json["name"] | "Unnamed";

            if (strlen(idStr) == 0)
            {
                return core2::ErrorCode::INVALID_ARGUMENT;
            }

            strncpy(p.id.data(), idStr, static_cast<size_t>(ProgramLimits::ID_MAX_LEN) - 1);
            strncpy(p.name.data(), nameStr, static_cast<size_t>(ProgramLimits::NAME_MAX_LEN) - 1);

            JsonArray steps = json["steps"].as<JsonArray>();
            if (steps.isNull())
            {
                return core2::ErrorCode::INVALID_ARGUMENT;
            }

            p.stepsCount = 0;
            for (JsonObject step : steps)
            {
                if (p.stepsCount >= static_cast<uint8_t>(ProgramLimits::MAX_STEPS))
                {
                    break;
                }

                // Новая логика полей: угол в градусах и задержка
                int angle = step["angle"] | 0;
                uint32_t sec = step["delaySec"] | 0;
                uint32_t ms = step["delayMs"] | 0;

                // Ограничиваем угол физическими пределами серво (0-180)
                if (angle < 0)
                    angle = 0;
                if (angle > 180)
                    angle = 180;

                p.steps.at(p.stepsCount).value = static_cast<int16_t>(angle);
                p.steps.at(p.stepsCount).durationMs = (sec * 1000) + ms;
                p.stepsCount++;
            }

            if (!p.isValid())
            {
                return core2::ErrorCode::INVALID_ARGUMENT;
            }

            return p;
        }
    };
}

#endif