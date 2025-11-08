#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <ArduinoJson.h>

// --- Настройки ---
const char* ssid = "Glider-Timer";
const char* password = ""; // Пароль не используется

// --- Глобальные объекты ---
ESP8266WebServer server(80);
// Используем статический JSON-документ - это самый надежный способ
StaticJsonDocument<128> statusDoc; 

// --- Обработчики HTTP запросов ---

// Обработчик для URL "/status", который использует Flutter-приложение
void handleStatus() {
  Serial.println("[HTTP] Received request for /status");
  
  statusDoc.clear(); // Очищаем документ перед новым использованием
  statusDoc["status"] = "ok";
  statusDoc["device"] = "GliderFlightCore_ESP8266";
  
  String output;
  serializeJson(statusDoc, output);
  
  // Отправляем ответ клиенту с правильным типом контента
  server.send(200, "application/json", output);
  Serial.print("[HTTP] Sent 200 OK with JSON: ");
  Serial.println(output);
}

// Обработчик для всех остальных URL
void handleNotFound() {
  Serial.println("[HTTP] Received request for unknown URL");
  server.send(404, "text/plain", "Not found");
  Serial.println("[HTTP] Sent 404 Not Found");
}

// --- Основные функции ---

void setup() {
  delay(1000); // Даем время на стабилизацию питания
  Serial.begin(115200);
  Serial.println("\n\n--- GliderFlightCore Firmware v0.1 ---");

  // --- Настройка Wi-Fi ---
  Serial.println("[WiFi] Starting Access Point...");
  // WiFi.mode(WIFI_AP); // Эта строка может быть полезна для принудительного режима
  
  if (WiFi.softAP(ssid, password)) {
    Serial.println("[WiFi] Access Point started successfully!");
    Serial.print("[INFO] SSID: ");
    Serial.println(ssid);
    Serial.print("[INFO] IP Address: ");
    Serial.println(WiFi.softAPIP());
  } else {
    Serial.println("[WiFi] FAILED to start Access Point. Halting.");
    while(1) {} // Остановка, если не удалось запустить AP
  }

  // --- Настройка Веб-сервера ---
  Serial.println("[WebServer] Configuring routes...");
  server.on("/status", handleStatus);
  server.onNotFound(handleNotFound); // Все, что не /status, получит 404
  
  server.begin();
  Serial.println("[WebServer] HTTP server started.");
  Serial.println("--- Setup Complete. Waiting for connections... ---");
}

void loop() {
  // Постоянно обрабатываем входящие HTTP-запросы
  server.handleClient();
}