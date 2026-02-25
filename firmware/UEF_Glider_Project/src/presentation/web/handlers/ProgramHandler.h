#ifndef PRESENTATION_WEB_HANDLERS_PROGRAM_H
#define PRESENTATION_WEB_HANDLERS_PROGRAM_H

#include "../ApiService.h"
#include <ArduinoJson.h>

namespace presentation::web::handlers
{
    /**
     * @brief Прием и сохранение полетной программы.
     */
    inline void handleProgramUpload(ApiService &api)
    {
        // Проверка блокировки конфига (Stage 2)
        if (api.flight().isConfigLocked())
        {
            api.server().send(403, "text/plain", "Forbidden: Config is locked in current mode");
            return;
        }

        if (!api.server().hasArg("plain"))
        {
            api.server().send(400, "text/plain", "Missing body");
            return;
        }

        StaticJsonDocument<2048> doc;
        auto error = deserializeJson(doc, api.server().arg("plain"));

        if (error)
        {
            api.server().send(400, "text/plain", "Invalid JSON");
            return;
        }

        domain::flight::FlightProgram p;
        strncpy(p.id, doc["id"] | "", domain::flight::ID_MAX_LEN);
        strncpy(p.name, doc["name"] | "Unnamed", domain::flight::NAME_MAX_LEN);

        JsonArray steps = doc["steps"];
        p.stepsCount = 0;

        for (JsonObject step : steps)
        {
            if (p.stepsCount >= domain::flight::MAX_STEPS)
                break;

            int direction = step["direction"] | 1;
            uint32_t sec = step["durationSec"] | 0;
            uint32_t ms = step["durationMs"] | 0;

            // Конвертация в SequenceStep (value, duration)
            // В старой прошивке value был углом, тут используем direction как множитель для теста
            p.steps[p.stepsCount].value = static_cast<int16_t>(direction * 90);
            p.steps[p.stepsCount].durationMs = (sec * 1000) + ms;
            p.stepsCount++;
        }

        if (api.program().saveProgram(p).isOk())
        {
            api.server().send(200, "text/plain", "OK");
        }
        else
        {
            api.server().send(500, "text/plain", "Storage Error");
        }
    }
}

#endif