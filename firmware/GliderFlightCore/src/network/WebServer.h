#ifndef WEB_SERVER_H
#define WEB_SERVER_H

#include <ESP8266WebServer.h>

namespace Network {
    // Глобальный экземпляр веб-сервера
    ESP8266WebServer server(80);

    /**
     * Обработчик для несуществующих маршрутов
     */
    void handleNotFound() {
        server.send(404, "text/plain", "Not found");
    }

    /**
     * Запуск веб-сервера
     */
    void startWebServer() {
        server.begin();
        Serial.println("[WebServer] Сервер запущен.");
    }

    /**
     * Основной цикл обработки HTTP-запросов
     */
    void processWebServer() {
        server.handleClient();
    }
}

#endif