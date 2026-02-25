/**
 * UEF 2.0: ПОЛНАЯ СИСТЕМА С ИНДИКАЦИЕЙ (STAGE 4)
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

// --- ИНФРАСТРУКТУРА ---
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
EventBus<> globalBus;
Scheduler<15> scheduler;

// Платформа и HAL
platform::ArduinoI2c i2cBus;
platform::Esp8266Barometer baroHal;
platform::DigitalInput hallPin(config::DEFAULT_HW_MAP.pinHall);
platform::DigitalOutput ledPin(config::DEFAULT_HW_MAP.pinLed1);
platform::Esp8266Network network;
platform::Esp8266Adc adc;
platform::Esp8266Timer sysTimer;
platform::Esp8266SystemInfo sysInfo;

// Драйверы
drivers::Bmp180 bmp(baroHal);
drivers::FlashStorage flash;
drivers::VccMonitor vcc(adc);
drivers::SystemMonitor sysMon(sysInfo, sysTimer);
drivers::LedChannel statusLed(ledPin, true); // true = инвертирован (для встроенного LED ESP8266)

// --- СЕРВИСЫ ---
PersistenceManager persistence(flash);
TelemetryService telemetry(bmp);
CalibrationService calib(bmp, persistence, globalBus);
ProgramManager programManager(persistence);
FlightService flight(network, globalBus);
HallSensorHandler hallHandler(hallPin, globalBus);
ApiService api(telemetry, calib, flight, programManager, vcc, sysMon);
IndicationService indication(statusLed);

void setup()
{
    Serial.begin(115200);
    delay(1000);
    Registry::injectLogger(&asyncLogger);

    asyncLogger.info("\n=== UEF 2.0: SYSTEM WITH INDICATION ===\n");

    if (!LittleFS.begin())
    {
        asyncLogger.error("FS: Ошибка LittleFS\n");
        indication.setError(true);
    }

    // 1. Инициализация железа
    i2cBus.init(config::DEFAULT_HW_MAP.pinI2cSda, config::DEFAULT_HW_MAP.pinI2cScl);
    network.setPower(true);
    WiFi.mode(WIFI_AP);
    WiFi.softAP("Glider-UEF-2", "");

    // 2. Инициализация сервисов
    if (!telemetry.begin().isOk())
    {
        asyncLogger.error("HW: Ошибка BMP180\n");
        indication.setError(true);
    }

    flight.init();
    api.begin();

    // Восстановление калибровки
    domain::telemetry::CalibrationProfile savedCal;
    if (persistence.load(StorageKey::CALIBRATION, savedCal).isOk())
    {
        telemetry.setBasePressure(savedCal.basePressure);
    }

    // 3. Подписки на события (Indication слушает всё)
    (void)globalBus.subscribe(static_cast<TypedEventListener<FlightStateEvent> *>(&indication));
    (void)globalBus.subscribe(static_cast<TypedEventListener<CalibrationEvent> *>(&indication));
    (void)globalBus.subscribe(static_cast<TypedEventListener<HallEvent> *>(&indication));
    (void)globalBus.subscribe(&flight);

    // 4. Планировщик
    scheduler.addTask(&telemetry, 5);
    scheduler.addTask(&calib, 10);
    scheduler.addTask(&hallHandler, 10);
    scheduler.addTask(&flight, 20);
    scheduler.addTask(&indication, 50); // Обновление LED каждые 50мс
    scheduler.addTask(&api, 100);

    asyncLogger.info("Индикация: SETUP-Медленно, ARMED-Двойной, FLIGHT-Вкл, CALIB-Быстро\n");
}

void loop()
{
    scheduler.run(millis());
    asyncLogger.flush(serialSink, 512);
}