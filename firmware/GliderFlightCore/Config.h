#ifndef CONFIG_H
#define CONFIG_H

#define VERSION "v0.4-baro-original"

const char* AP_SSID = "Glider-Timer";
const char* AP_PASS = "";

// Пины
const int PIN_BUTTON = 0;   
const int PIN_LED    = 2;   

// Настройки сенсоров (синхронизировано с оригиналом)
const unsigned long BARO_INTERVAL = 2000; 
const int STABLE_THRESHOLD = 5;

#endif