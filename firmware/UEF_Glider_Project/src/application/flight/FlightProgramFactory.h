#ifndef APPLICATION_FLIGHT_PROGRAM_FACTORY_H
#define APPLICATION_FLIGHT_PROGRAM_FACTORY_H

#include "../../domain/flight/FlightProgram.h"
#include "../../core2/base/Result.h"
#include <ArduinoJson.h>

namespace application::flight
{
    /**
     * @brief Фабрика для создания доменных моделей из внешних форматов.
     * Изолирует инфраструктурную зависимость от ArduinoJson.
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

            // Исправлено: использование квалифицированных имен из ProgramLimits и доступ к std::array через .data()
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

                int direction = step["direction"] | 1;
                uint32_t sec = step["durationSec"] | 0;
                uint32_t ms = step["durationMs"] | 0;

                // Исправлено: доступ к std::array через .at()
                p.steps.at(p.stepsCount).value = static_cast<int16_t>(direction * 90);
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