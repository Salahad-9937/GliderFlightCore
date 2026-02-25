/**
 * UEF 2.0: ПОЛНАЯ ИНТЕГРАЦИЯ (STAGE 3) - FIXED NAMESPACES
 *
 * Проверка:
 * 1. Работа REST API (/status, /program, /system).
 * 2. Блокировка деструктивных действий в режиме ARMED.
 * 3. Полное отключение API в режиме FLIGHT (через WiFi OFF).
 */

#include <Arduino.h>
#include <LittleFS.h>
#include <ESP8266WiFi.h>

#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/core2/messaging/EventBus.h"
#include "src/core2/engine/Scheduler.h"
#include "src/platforms/esp8266/Esp8266Platform.h"

// Драйверы
#include "src/drivers/sensors/Bmp180.h"
#include "src/drivers/storage/FlashStorage.h"
#include "src/drivers/power/VccMonitor.h"
#include "src/drivers/system/SystemMonitor.h"

// Сервисы
#include "src/infrastructure/persistence/PersistenceManager.h"
#include "src/application/telemetry/TelemetryService.h"
#include "src/application/calibration/CalibrationService.h"
#include "src/application/flight/FlightService.h"
#include "src/application/flight/ProgramManager.h"
#include "src/presentation/input/HallSensorHandler.h"
#include "src/presentation/web/ApiService.h"

// Раскрытие пространств имен для удобства в .ino файле
using namespace core2;
using namespace infrastructure::persistence;
using namespace application::telemetry;
using namespace application::calibration;
using namespace application::flight;
using namespace presentation::input;
using namespace presentation::web;

// --- ИНФРАСТРУКТУРА ---
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
EventBus<> globalBus;
Scheduler<12> scheduler;

// Платформа и HAL
platform::ArduinoI2c i2cBus;
platform::Esp8266Barometer baroHal;
platform::DigitalInput hallPin(config::DEFAULT_HW_MAP.pinHall);
platform::Esp8266Network network;
platform::Esp8266Adc adc;
platform::Esp8266Timer sysTimer;
platform::Esp8266SystemInfo sysInfo;

// Драйверы
drivers::Bmp180 bmp(baroHal);
drivers::FlashStorage flash;
drivers::VccMonitor vcc(adc);
drivers::SystemMonitor sysMon(sysInfo, sysTimer);

// --- СЕРВИСЫ ---
PersistenceManager persistence(flash);
TelemetryService telemetry(bmp);
CalibrationService calib(bmp, persistence, globalBus);
ProgramManager programManager(persistence);
FlightService flight(network, globalBus);
HallSensorHandler hallHandler(hallPin, globalBus);
ApiService api(telemetry, calib, flight, programManager, vcc, sysMon);

void setup()
{
    Serial.begin(115200);
    delay(1000);
    Registry::injectLogger(&asyncLogger);

    asyncLogger.info("\n=== UEF 2.0: FULL SYSTEM INTEGRATION ===\n");

    if (!LittleFS.begin())
    {
        asyncLogger.error("FS: Ошибка LittleFS\n");
    }

    // 1. Инициализация железа
    i2cBus.init(config::DEFAULT_HW_MAP.pinI2cSda, config::DEFAULT_HW_MAP.pinI2cScl);

    // Явная настройка Wi-Fi точки доступа
    network.setPower(true);
    WiFi.mode(WIFI_AP);
    WiFi.softAP("Glider-UEF-2", "");

    // 2. Инициализация сервисов
    (void)telemetry.begin();
    flight.init();
    api.begin();

    // Восстановление калибровки из Flash при старте
    domain::telemetry::CalibrationProfile savedCal;
    if (persistence.load(StorageKey::CALIBRATION, savedCal).isOk())
    {
        asyncLogger.info("FS: Калибровка восстановлена\n");
        telemetry.setBasePressure(savedCal.basePressure);
    }

    // 3. Подписки на события
    (void)globalBus.subscribe(&flight);

    // 4. Регистрация задач в планировщике
    (void)scheduler.addTask(&telemetry, 5);    // Опрос датчика (высокий приоритет)
    (void)scheduler.addTask(&calib, 10);       // Логика калибровки
    (void)scheduler.addTask(&hallHandler, 10); // Обработка магнита
    (void)scheduler.addTask(&flight, 20);      // Машина состояний полета
    (void)scheduler.addTask(&api, 50);         // Обработка HTTP запросов

    asyncLogger.info("Система запущена. IP: 192.168.4.1\n");
}

void loop()
{
    // Запуск планировщика
    scheduler.run(millis());

    // Сброс накопленных логов в Serial (неблокирующий)
    asyncLogger.flush(serialSink, 512);
}