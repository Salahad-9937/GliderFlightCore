#ifndef PRESENTATION_WEB_HANDLERS_PROGRAM_H
#define PRESENTATION_WEB_HANDLERS_PROGRAM_H

#include "../ApiService.h"
#include "../../../application/flight/FlightProgramFactory.h"
#include <ArduinoJson.h>

namespace presentation::web::handlers
{
    /**
     * @brief Прием и сохранение полетной программы.
     * Реализует Layering: UI -> Factory -> Manager.
     */
    inline void handleProgramUpload(ApiService &api)
    {
        if (api.flight().isConfigLocked())
        {
            api.server().send(403, "application/json", "{\"error\":\"config_locked\"}");
            return;
        }

        if (!api.server().hasArg("plain"))
        {
            api.server().send(400, "application/json", "{\"error\":\"empty_body\"}");
            return;
        }

        // Исправлено: замена StaticJsonDocument на JsonDocument (ArduinoJson v7)
        JsonDocument doc;
        if (deserializeJson(doc, api.server().arg("plain")))
        {
            api.server().send(400, "application/json", "{\"error\":\"invalid_json\"}");
            return;
        }

        // Использование фабрики для создания доменного объекта (Pattern: Factory)
        auto createRes = application::flight::FlightProgramFactory::createFromJson(doc.as<JsonVariant>());

        if (!createRes.isOk())
        {
            api.server().send(400, "application/json", "{\"error\":\"validation_failed\"}");
            return;
        }

        // Сохранение через менеджер
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