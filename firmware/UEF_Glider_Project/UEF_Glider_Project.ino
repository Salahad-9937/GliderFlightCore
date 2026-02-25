/**
 * UEF 2.0: FINAL RELEASE (STAGE 5)
 *
 * Полная интеграция:
 * - Телеметрия (BMP180 + Kalman)
 * - Управление (Hall Sensor Gestures)
 * - Полет (Sequencer + Servo + Pressure Logging)
 * - Сеть (REST API + WiFi Power Management)
 * - Защита (Hardware Watchdog + CRC16 Persistence)
 * - Индикация (LED Patterns)
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
#include "src/drivers/led/LedChannel.h"

// Сервисы
#include "src/infrastructure/persistence/PersistenceManager.h"
#include "src/application/telemetry/TelemetryService.h"
#include "src/application/calibration/CalibrationService.h"
#include "src/application/flight/FlightService.h"
#include "src/application/flight/ProgramManager.h"
#include "src/presentation/input/HallSensorHandler.h"
#include "src/presentation/web/ApiService.h"
#include "src/presentation/indication/IndicationService.h"

using namespace core2;
using namespace infrastructure::persistence;
using namespace application::telemetry;
using namespace application::calibration;
using namespace application::flight;
using namespace presentation::input;
using namespace presentation::web;
using namespace presentation::indication;

// КРИТИЧЕСКИЙ МАКРОС ДЛЯ ESP8266: Переключение АЦП в режим замера VCC
ADC_MODE(ADC_VCC);

// --- ИНФРАСТРУКТУРА ---
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
EventBus<> globalBus;
Scheduler<15> scheduler;
platform::Esp8266Lock globalLock;

// Платформа и HAL
platform::ArduinoI2c i2cBus;
platform::Esp8266Barometer baroHal;
platform::DigitalInput hallPin(config::DEFAULT_HW_MAP.pinHall);
platform::DigitalOutput ledPin(config::DEFAULT_HW_MAP.pinLed1);
platform::ServoActuator servoHal(config::DEFAULT_HW_MAP.pinServo);
platform::Esp8266Network network;
platform::Esp8266Adc adc;
platform::Esp8266Timer sysTimer;
platform::Esp8266SystemInfo sysInfo;
platform::Esp8266Watchdog wdt;

// Драйверы
drivers::Bmp180 bmp(baroHal);
drivers::FlashStorage flash;
drivers::VccMonitor vcc(adc);
drivers::SystemMonitor sysMon(sysInfo, sysTimer);
drivers::LedChannel statusLed(ledPin, true);

// --- СЕРВИСЫ ---
PersistenceManager persistence(flash);
TelemetryService telemetry(bmp);
CalibrationService calib(bmp, persistence, globalBus);
ProgramManager programManager(persistence);
FlightService flight(network, servoHal, flash, programManager, telemetry, globalBus);
HallSensorHandler hallHandler(hallPin, globalBus);
ApiService api(telemetry, calib, flight, programManager, vcc, sysMon);
IndicationService indication(statusLed);

void setup()
{
    // 1. Базовая инициализация
    Serial.begin(config::DEFAULT_HW_MAP.baudRate);
    delay(500);

    Registry::injectLogger(&asyncLogger);
    Registry::injectLock(&globalLock);

    asyncLogger.info("\n=== GliderFlightCore UEF 2.0 START ===\n");

    if (!LittleFS.begin())
    {
        asyncLogger.error("FS: Ошибка LittleFS\n");
        indication.setError(true);
    }

    // 2. Инициализация железа
    i2cBus.init(config::DEFAULT_HW_MAP.pinI2cSda, config::DEFAULT_HW_MAP.pinI2cScl);
    wdt.begin(4000); // Watchdog на 4 секунды

    network.setPower(true);
    WiFi.mode(WIFI_AP);
    WiFi.softAP("Glider-UEF-2", "");

    // 3. Инициализация логики
    if (!telemetry.begin().isOk())
    {
        asyncLogger.error("HW: Ошибка BMP180\n");
        indication.setError(true);
    }

    // Загрузка настроек
    (void)programManager.loadActiveProgram();
    domain::telemetry::CalibrationProfile savedCal;
    if (persistence.load(StorageKey::CALIBRATION, savedCal).isOk())
    {
        telemetry.setBasePressure(savedCal.basePressure);
    }

    flight.init();
    api.begin();

    // 4. Подписки
    (void)globalBus.subscribe(static_cast<TypedEventListener<FlightStateEvent> *>(&indication));
    (void)globalBus.subscribe(static_cast<TypedEventListener<CalibrationEvent> *>(&indication));
    (void)globalBus.subscribe(static_cast<TypedEventListener<HallEvent> *>(&indication));
    (void)globalBus.subscribe(&flight);

    // 5. Планировщик (Приоритеты: Телеметрия > Ввод > FSM > Индикация > API)
    scheduler.addTask(&telemetry, 5);    // 200 Hz
    scheduler.addTask(&hallHandler, 10); // 100 Hz
    scheduler.addTask(&calib, 20);       // 50 Hz
    scheduler.addTask(&flight, 20);      // 50 Hz
    scheduler.addTask(&indication, 50);  // 20 Hz
    scheduler.addTask(&api, 100);        // 10 Hz

    asyncLogger.info("Система готова к эксплуатации.\n");
}

void loop()
{
    uint32_t now = millis();

    // Выполнение задач
    scheduler.run(now);

    // Сброс WDT
    wdt.kick();

    // Вывод логов
    asyncLogger.flush(serialSink, 512);
}