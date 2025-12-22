#include "Config.h"
#include "Storage.h"
#include "Sensors.h"
#include "Network.h"

void setup() {
    delay(500);
    Serial.begin(115200);
    Serial.println("\n--- GliderFlightCore " VERSION " ---");

    Storage::begin();
    Sensors::begin(); // Теперь мгновенный запуск
    Network::setup();

    pinMode(PIN_LED, OUTPUT);
    pinMode(PIN_BUTTON, INPUT_PULLUP);
    
    digitalWrite(PIN_LED, HIGH);
    Serial.println("--- System Ready (Idle Mode) ---");
}

void loop() {
    Network::loop();
    Sensors::update(); 
}