#ifndef CONFIG_H
#define CONFIG_H

#define VERSION "v0.6-hall-advanced"

const char *AP_SSID = "Glider-Timer";
const char *AP_PASS = "";

// Пины
const int PIN_HALL = 2;
const int PIN_LED = 16;

// Тайминги кнопки (Hall Sensor)
const unsigned long DEBOUNCE_MS = 50;
const unsigned long LONG_PRESS_MS = 3000;
const unsigned long DOUBLE_CLICK_MS = 500; // Окно для второго клика

// Настройки сенсоров
const unsigned long BARO_INTERVAL = 500;
const int STABLE_THRESHOLD = 5;

// Файлы системы
#define CALIB_FILE "/calib.json"

#endif