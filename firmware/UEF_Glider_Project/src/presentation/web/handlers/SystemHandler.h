#ifndef PRESENTATION_WEB_HANDLERS_SYSTEM_H
#define PRESENTATION_WEB_HANDLERS_SYSTEM_H

#include "../ApiService.h"
#include <ArduinoJson.h>

namespace presentation::web::handlers
{
    /**
     * @brief Обработчик расширенной диагностики системы.
     */
    inline void handleSystem(ApiService &api)
    {
        auto reportRes = api.sys().getReport();
        if (!reportRes.isOk())
        {
            api.server().send(500, "text/plain", "System Monitor Error");
            return;
        }

        auto r = reportRes.value();
        // Исправлено: замена StaticJsonDocument на JsonDocument (ArduinoJson v7)
        JsonDocument doc;

        doc["uptime"] = r.uptimeSec;
        doc["free_heap"] = r.freeHeap;
        doc["fs_total"] = r.fsTotalBytes;
        doc["fs_used"] = r.fsUsedBytes;
        doc["fs_load"] = r.fsLoadPercent;
        doc["chip_id"] = String(ESP.getChipId(), HEX);
        doc["version"] = "UEF 2.0-STAGE3";

        String output;
        serializeJson(doc, output);
        api.server().send(200, "application/json", output);
    }
}

#endif