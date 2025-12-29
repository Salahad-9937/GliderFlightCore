#ifndef CONFIG_H
#define CONFIG_H

#define VERSION "v0.4-baro-0.5s"

const char* AP_SSID = "Glider-Timer";
const char* AP_PASS = "";

// Пины
const int PIN_BUTTON = 0;   
const int PIN_LED    = 2;   

// Настройки сенсоров
// Интервал опроса уменьшен до 500 мс (2 Гц)
const unsigned long BARO_INTERVAL = 500; 
const int STABLE_THRESHOLD = 5;

// Файлы системы
#define CALIB_FILE "/calib.json"

#endif