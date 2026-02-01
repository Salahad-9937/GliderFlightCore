#ifndef CONFIG_H
#define CONFIG_H

#include "PinConfig.h"

#define VERSION "v0.7-dynamic-pins"

const char *AP_SSID = "Glider-Timer";
const char *AP_PASS = "";

// Глобальный объект конфигурации пинов
extern Config::PinConfig pins;

// Тайминги кнопки (Hall Sensor)
const unsigned long DEBOUNCE_MS = 50;
const unsigned long LONG_PRESS_MS = 3000;
const unsigned long DOUBLE_CLICK_MS = 500;

// Настройки сенсоров
const unsigned long BARO_INTERVAL = 500;
const int STABLE_THRESHOLD = 5;

// Файлы системы
#define CALIB_FILE "/calib.json"
#define PINS_FILE "/pins.json"

#endif