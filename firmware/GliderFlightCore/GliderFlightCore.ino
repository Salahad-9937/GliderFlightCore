#include "src/config/Config.h"
#include "src/core/Storage.h"
#include "src/core/Sensors.h"
#include "src/core/Network.h"
#include "src/core/FlightManager.h"

// Переключение АЦП в режим измерения напряжения питания (VCC)
ADC_MODE(ADC_VCC);

void setup()
{
    delay(500);
    Serial.begin(115200);
    Serial.println("\n--- GliderFlightCore " VERSION " ---");

    Storage::begin();
    Sensors::begin();
    Flight::setup(); // Инициализация кнопки Холла
    Network::setup();

    pinMode(PIN_LED, OUTPUT);
    digitalWrite(PIN_LED, HIGH);

    Serial.println("--- System Ready (Idle Mode) ---");
}

void loop()
{
    // В режиме полета (FLIGHT) веб-сервер не будет обрабатывать запросы,
    // так как Wi-Fi физически отключен в FlightManager.
    Network::loop();

    Sensors::update();
    Flight::update(); // Обработка логики полета и кнопки
}