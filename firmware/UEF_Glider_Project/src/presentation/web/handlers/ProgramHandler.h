#ifndef PRESENTATION_WEB_HANDLERS_PROGRAM_H
#define PRESENTATION_WEB_HANDLERS_PROGRAM_H

#include "../ApiService.h"
#include "../../../application/flight/FlightProgramFactory.h"
#include <ArduinoJson.h>

namespace presentation::web::handlers
{
    /**
     * @brief Прием и сохранение полетной программы.
     * Реализует Layering: API -> Factory -> Manager -> Persistence.
     */
    inline void handleProgramUpload(ApiService &api)
    {
        // 1. Проверка состояния (нельзя менять программу в полете или в режиме Armed)
        if (api.flight().isConfigLocked())
        {
            api.server().send(403, "application/json", "{\"error\":\"config_locked\"}");
            return;
        }

        // 2. Проверка наличия тела запроса
        if (!api.server().hasArg("plain"))
        {
            api.server().send(400, "application/json", "{\"error\":\"empty_body\"}");
            return;
        }

        // 3. Парсинг JSON (ArduinoJson v7)
        JsonDocument doc;
        DeserializationError error = deserializeJson(doc, api.server().arg("plain"));

        if (error)
        {
            api.server().send(400, "application/json", "{\"error\":\"invalid_json\"}");
            return;
        }

        // 4. Создание доменного объекта через фабрику (уже поддерживает angle/delay)
        auto createRes = application::flight::FlightProgramFactory::createFromJson(doc.as<JsonVariant>());

        if (!createRes.isOk())
        {
            api.server().send(400, "application/json", "{\"error\":\"validation_failed\"}");
            return;
        }

        // 5. Сохранение и активация программы через менеджер
        if (api.program().saveProgram(createRes.value()).isOk())
        {
            api.server().send(200, "application/json", "{\"status\":\"ok\"}");
        }
        else
        {
            api.server().send(500, "application/json", "{\"error\":\"storage_failure\"}");
        }
    }
}

#endif