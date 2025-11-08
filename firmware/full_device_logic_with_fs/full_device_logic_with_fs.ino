#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>
#include <LittleFS.h> // Подключаем библиотеку для файловой системы

// --- Настройки ---
const char* ssid = "Glider-Timer";
const char* password = "";

// --- Глобальные объекты ---
ESP8266WebServer server(80);
StaticJsonDocument<128> statusDoc;
// Увеличим размер документа для приема полетной программы
// 1024 байта должно хватить для программы с ~20-30 шагами
StaticJsonDocument<1024> programDoc;

// --- Обработчики HTTP запросов ---

void handleStatus() {
  // ... (код без изменений)
  Serial.println("[HTTP] Received request for /status");
  statusDoc.clear();
  statusDoc["status"] = "ok";
  statusDoc["device"] = "GliderFlightCore_ESP8266";
  String output;
  serializeJson(statusDoc, output);
  server.send(200, "application/json", output);
  Serial.print("[HTTP] Sent 200 OK with JSON: ");
  Serial.println(output);
}

// НОВЫЙ ОБРАБОТЧИК для загрузки программы
void handleProgramUpload() {
  Serial.println("[HTTP] Received POST request for /program");

  // Проверяем, есть ли у запроса тело (plain body)
  if (server.hasArg("plain") == false) {
    server.send(400, "text/plain", "Bad Request: No body");
    Serial.println("[HTTP] Sent 400 Bad Request");
    return;
  }

  String body = server.arg("plain");
  Serial.print("[Program] Received JSON: ");
  Serial.println(body);

  // Пытаемся десериализовать полученный JSON
  DeserializationError error = deserializeJson(programDoc, body);
  if (error) {
    Serial.print("[Program] JSON deserialization failed: ");
    Serial.println(error.c_str());
    server.send(400, "text/plain", "Bad Request: Invalid JSON");
    return;
  }

  // Сохраняем JSON в файл "program.json"
  File programFile = LittleFS.open("/program.json", "w");
  if (!programFile) {
    Serial.println("[FS] Failed to open program.json for writing");
    server.send(500, "text/plain", "Internal Server Error");
    return;
  }
  
  serializeJson(programDoc, programFile);
  programFile.close();
  
  Serial.println("[FS] Program saved to /program.json successfully.");
  server.send(200, "text/plain", "OK");
}

void handleNotFound() {
  // ... (код без изменений)
  Serial.println("[HTTP] Received request for unknown URL");
  server.send(404, "text/plain", "Not found");
  Serial.println("[HTTP] Sent 404 Not Found");
}

// --- Основные функции ---

void setup() {
  delay(1000);
  Serial.begin(115200);
  Serial.println("\n\n--- GliderFlightCore Firmware v0.2 (with FS) ---");

  // Инициализация файловой системы LittleFS
  if (!LittleFS.begin()) {
    Serial.println("[FS] Failed to mount file system. Halting.");
    while(1) {}
  }
  Serial.println("[FS] File system mounted.");

  // ... (код настройки Wi-Fi без изменений) ...
  Serial.println("[WiFi] Starting Access Point...");
  if (WiFi.softAP(ssid, password)) {
    Serial.println("[WiFi] Access Point started successfully!");
    Serial.print("[INFO] SSID: ");
    Serial.println(ssid);
    Serial.print("[INFO] IP Address: ");
    Serial.println(WiFi.softAPIP());
  } else {
    Serial.println("[WiFi] FAILED to start Access Point. Halting.");
    while(1) {}
  }
  
  // --- Настройка Веб-сервера ---
  Serial.println("[WebServer] Configuring routes...");
  server.on("/status", HTTP_GET, handleStatus);
  // Регистрируем новый обработчик для POST запросов на /program
  server.on("/program", HTTP_POST, handleProgramUpload);
  server.onNotFound(handleNotFound);
  
  server.begin();
  Serial.println("[WebServer] HTTP server started.");
  Serial.println("--- Setup Complete. Waiting for connections... ---");
}

void loop() {
  server.handleClient();
}