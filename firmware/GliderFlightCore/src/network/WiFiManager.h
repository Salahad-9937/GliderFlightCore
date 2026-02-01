#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H

#include <ESP8266WiFi.h>
#include "../config/Config.h"

namespace Network
{
    /**
     * Настройка точки доступа Wi-Fi.
     * Вызывается при старте и при выходе из режима полета.
     */
    void setupWiFi()
    {
        Serial.println("[WiFi] Активация радиомодуля...");

        // Пробуждение после forceSleepBegin
        WiFi.forceSleepWake();
        delay(1);

        WiFi.mode(WIFI_AP);
        if (WiFi.softAP(AP_SSID, AP_PASS))
        {
            Serial.print("[WiFi] Точка доступа готова. IP: ");
            Serial.println(WiFi.softAPIP());
        }
    }

    /**
     * Полное отключение Wi-Fi для экономии энергии в полете
     */
    void stopWiFi()
    {
        WiFi.softAPdisconnect(true);
        WiFi.mode(WIFI_OFF);
        WiFi.forceSleepBegin();
        delay(1);
        Serial.println("[WiFi] Радиомодуль полностью отключен.");
    }
}

#endif