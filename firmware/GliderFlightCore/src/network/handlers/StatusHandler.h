#ifndef STATUS_HANDLER_H
#define STATUS_HANDLER_H

#include <ArduinoJson.h>
#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network
{
    /**
     * Возвращает полный статус устройства (Телеметрия).
     * Теперь метод максимально прост и не требует правок при изменении структуры датчиков.
     */
    void handleStatus()
    {
        Serial.println("[HTTP] Запрос статуса /status");

        StaticJsonDocument<512> doc;
        JsonObject obj = doc.to<JsonObject>();

        // Делегируем сборку данных самому слою Sensors
        Sensors::serializeFullStatus(obj);

        String output;
        serializeJson(doc, output);
        server.send(200, "application/json", output);

        Serial.print("[HTTP] Ответ отправлен: ");
        Serial.println(output);
    }
}
#endif