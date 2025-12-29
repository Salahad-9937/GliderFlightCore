#include "src/config/Config.h"
#include "src/core/Storage.h"
#include "src/core/Sensors.h"
#include "src/core/Network.h"

// Переключение АЦП в режим измерения напряжения питания (VCC)
// В этом режиме чтение аналогового пина A0 становится невозможным.
ADC_MODE(ADC_VCC);

void setup() {
    delay(500);
    Serial.begin(115200);
    Serial.println("\n--- GliderFlightCore " VERSION " ---");

    Storage::begin();
    Sensors::begin();
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