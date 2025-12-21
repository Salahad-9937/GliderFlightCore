#ifndef NETWORK_H
#define NETWORK_H

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>
#include "Config.h"
#include "Storage.h"

ESP8266WebServer server(80);

namespace Network {
    void handleStatus() {
        Serial.println("[HTTP] Received request for /status");
        StaticJsonDocument<128> doc;
        doc["status"] = "ok";
        doc["device"] = "GliderFlightCore_ESP8266";
        doc["version"] = VERSION;
        
        String output;
        serializeJson(doc, output);
        server.send(200, "application/json", output);
        Serial.print("[HTTP] Sent 200 OK: ");
        Serial.println(output);
    }

    void handleProgramUpload() {
        Serial.println("[HTTP] Received POST request for /program");
        
        if (!server.hasArg("plain")) {
            server.send(400, "text/plain", "Bad Request: No body");
            Serial.println("[HTTP] Sent 400: No body");
            return;
        }

        String body = server.arg("plain");
        Serial.println("[Program] Received JSON string:");
        Serial.println(body);

        // Проверяем валидность JSON перед записью
        StaticJsonDocument<1024> tempDoc;
        DeserializationError error = deserializeJson(tempDoc, body);
        
        if (error) {
            Serial.print("[Program] JSON Deserialization failed: ");
            Serial.println(error.c_str());
            server.send(400, "text/plain", "Invalid JSON");
            return;
        }

        if (Storage::saveProgram(body)) {
            server.send(200, "text/plain", "OK");
            Serial.println("[HTTP] Sent 200 OK");
        } else {
            server.send(500, "text/plain", "Internal Storage Error");
            Serial.println("[HTTP] Sent 500: FS Error");
        }
    }

    void handleNotFound() {
        Serial.print("[HTTP] Unknown URL requested: ");
        Serial.println(server.uri());
        server.send(404, "text/plain", "Not found");
    }

    void setup() {
        Serial.println("[WiFi] Starting Access Point...");
        if (WiFi.softAP(AP_SSID, AP_PASS)) {
            Serial.println("[WiFi] Access Point started successfully!");
            Serial.print("[INFO] SSID: ");
            Serial.println(AP_SSID);
            Serial.print("[INFO] IP Address: ");
            Serial.println(WiFi.softAPIP());
        } else {
            Serial.println("[WiFi] FAILED to start AP. Halting.");
            while(1) delay(100);
        }

        Serial.println("[WebServer] Configuring routes...");
        server.on("/status", HTTP_GET, handleStatus);
        server.on("/program", HTTP_POST, handleProgramUpload);
        server.onNotFound(handleNotFound);
        
        server.begin();
        Serial.println("[WebServer] HTTP server started.");
    }

    void loop() {
        server.handleClient();
    }
}
#endif