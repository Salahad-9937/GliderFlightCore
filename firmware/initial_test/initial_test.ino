#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

// Имя сети, которую создаст плата
const char* ssid = "Glider-AP-Test";

// Создаем объект сервера
ESP8266WebServer server(80);

// Эта функция будет отвечать на запросы
void handleRequest() {
  server.send(200, "text/plain", "OK"); // Отправляем простой ответ "OK"
  Serial.println("Handled a request."); // Логируем, что запрос был
}

void setup() {
  // Даем плате секунду на стабилизацию после включения
  delay(1000);

  // Запускаем Serial порт
  Serial.begin(115200);
  Serial.println("\n--- Starting Basic Server Test ---");

  // Запускаем точку доступа (Access Point)
  Serial.print("Configuring access point...");
  bool success = WiFi.softAP(ssid);
  
  if (success) {
    Serial.println(" OK");
    Serial.print("AP IP address: ");
    Serial.println(WiFi.softAPIP());

    // Настраиваем сервер отвечать на все запросы одной функцией
    // и для "/" и для "/status"
    server.on("/", handleRequest);
    server.on("/status", handleRequest);

    // Запускаем сервер
    server.begin();
    Serial.println("HTTP server started. Waiting for requests...");
  } else {
    Serial.println(" FAILED!");
    Serial.println("Could not start Access Point. Halting.");
    while(1) {} // Бесконечный цикл, если не удалось запустить AP
  }
}

void loop() {
  // Эта функция обязательна. Она проверяет, не пришел ли новый запрос.
  server.handleClient();
}