#include "Config.h"
#include "Storage.h"
#include "Network.h"

void setup() {
    delay(1000); // Даем железу стабилизироваться
    Serial.begin(115200);
    Serial.println("\n\n--- GliderFlightCore Firmware " VERSION " ---");

    Storage::begin();
    Network::setup();

    pinMode(PIN_LED, OUTPUT);
    pinMode(PIN_BUTTON, INPUT_PULLUP);
    
    // Включаем LED на секунду, показывая, что setup прошел
    digitalWrite(PIN_LED, LOW); 
    delay(1000);
    digitalWrite(PIN_LED, HIGH);

    Serial.println("--- Setup Complete. System Ready. ---");
}

void loop() {
    Network::loop();
}