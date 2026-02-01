#ifndef CONFIG_H
#define CONFIG_H

#define VERSION "v0.5-flight-logic"

const char *AP_SSID = "Glider-Timer";
const char *AP_PASS = "";

// Пины
const int PIN_HALL = 2; // Датчик Холла (магнитная кнопка)
const int PIN_LED = 16; // Перенесено с GPIO 2 (не подключен)

// Тайминги кнопки
const unsigned long DEBOUNCE_MS = 50;
const unsigned long LONG_PRESS_MS = 3000;

// Настройки сенсоров
const unsigned long BARO_INTERVAL = 500;
const int STABLE_THRESHOLD = 5;

// Файлы системы
#define CALIB_FILE "/calib.json"

#endif