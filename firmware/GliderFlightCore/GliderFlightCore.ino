#include "src/config/Config.h"
#include "src/core/Storage.h"
#include "src/core/Sensors.h"
#include "src/core/Network.h"
#include "src/core/FlightManager.h"

// Определение глобального объекта пинов
Config::PinConfig pins;

ADC_MODE(ADC_VCC);

void setup()
{
    delay(500);
    Serial.begin(115200);
    Serial.println("\n--- GliderFlightCore " VERSION " ---");

    // 1. Сначала ФС и загрузка пинов
    Storage::begin();
    Storage::loadPins(pins);

    // 2. Инициализация базовой периферии
    pinMode(pins.led, OUTPUT);
    digitalWrite(pins.led, HIGH);

    // 3. Инициализация подсистем (теперь они видят загруженные пины)
    Sensors::begin();
    Flight::setup();
    Network::setup();

    Serial.println("--- System Ready (Idle Mode) ---");
}

void loop()
{
    Network::loop();
    Sensors::update();
    Flight::update();
}