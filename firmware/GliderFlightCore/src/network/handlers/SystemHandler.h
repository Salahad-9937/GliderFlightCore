#ifndef SYSTEM_HANDLER_H
#define SYSTEM_HANDLER_H

#include <ArduinoJson.h>
#include <LittleFS.h>
#include "../WebServer.h"

namespace Network
{
    /**
     * Обработчик расширенной диагностики системы
     */
    void handleSystem()
    {
        Serial.println("[HTTP] Запрос диагностики /system");

        StaticJsonDocument<256> doc;

        // Время работы в секундах
        doc["uptime"] = millis() / 1000;

        // Свободная оперативная память (SRAM)
        doc["free_heap"] = ESP.getFreeHeap();

        // Информация о файловой системе
        FSInfo fs_info;
        if (LittleFS.info(fs_info))
        {
            doc["fs_total"] = fs_info.totalBytes;
            doc["fs_used"] = fs_info.usedBytes;
        }

        // Идентификатор чипа
        doc["chip_id"] = String(ESP.getChipId(), HEX);

        // Версия прошивки (из Config.h)
        doc["version"] = VERSION;

        String output;
        serializeJson(doc, output);
        server.send(200, "application/json", output);
        Serial.println("[HTTP] Ответ отправлен (System Health)");
        Serial.println(output);
    }
}

#endif