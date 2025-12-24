#ifndef WIFI_MANAGER_H
#define WIFI_MANAGER_H

#include <ESP8266WiFi.h>
#include "../config/Config.h"

namespace Network {
    /**
     * Настройка точки доступа Wi-Fi
     */
    void setupWiFi() {
        Serial.println("[WiFi] Запуск точки доступа...");
        if (WiFi.softAP(AP_SSID, AP_PASS)) {
            Serial.print("[WiFi] IP-адрес: ");
            Serial.println(WiFi.softAPIP());
        }
    }
}

#endif