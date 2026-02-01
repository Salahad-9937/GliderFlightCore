#ifndef PROGRAM_HANDLER_H
#define PROGRAM_HANDLER_H

#include <ArduinoJson.h>
#include "../../core/Storage.h"
#include "../WebServer.h"

namespace Network
{

    /**
     * Валидация и парсинг JSON программы (Extract Method)
     */
    bool processProgramJson(String body)
    {
        StaticJsonDocument<1024> tempDoc;
        DeserializationError error = deserializeJson(tempDoc, body);

        if (error)
        {
            server.send(400, "text/plain", "Invalid JSON");
            Serial.print("[HTTP] Ошибка парсинга программы: ");
            Serial.println(error.c_str());
            return false;
        }
        return true;
    }

    /**
     * Загрузка полетной программы
     */
    void handleProgramUpload()
    {
        Serial.println("[HTTP] Загрузка программы /program");

        if (!server.hasArg("plain"))
        {
            server.send(400, "text/plain", "Bad Request: No body");
            return;
        }

        String body = server.arg("plain");

        if (!processProgramJson(body))
        {
            return; // Ошибка уже отправлена в processProgramJson
        }

        if (Storage::saveProgram(body))
        {
            server.send(200, "text/plain", "OK");
            Serial.println("[HTTP] Программа сохранена успешно");
        }
        else
        {
            server.send(500, "text/plain", "FS Error");
        }
    }
}
#endif