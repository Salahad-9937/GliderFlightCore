/**
 * UEF 2.0: ПОДРОБНЫЙ ТЕСТ ЭТАПА 2 (FLIGHT FSM) - FIXED
 */

#include <Arduino.h>
#include <LittleFS.h>
#include <ESP8266WiFi.h>

#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/core2/messaging/EventBus.h"
#include "src/core2/messaging/EventListener.h"
#include "src/core2/engine/Scheduler.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/presentation/input/HallSensorHandler.h"
#include "src/application/flight/FlightService.h"

using namespace core2;
using namespace application::flight;
using namespace application::events;
using namespace presentation::input;

// --- ИНФРАСТРУКТУРА ---
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
EventBus<> globalBus;
Scheduler<8> scheduler;

platform::DigitalInput hallPin(config::DEFAULT_HW_MAP.pinHall);
platform::Esp8266Network network;

// --- СЕРВИСЫ ---
HallSensorHandler hallHandler(hallPin, globalBus);
FlightService flightService(network, globalBus);

// --- МОНИТОРИНГ СОБЫТИЙ ---
class EventMonitor : public TypedEventListener<HallEvent>,
                     public TypedEventListener<FlightStateEvent>
{
public:
    void onTypedEvent(const HallEvent &e) override
    {
        const char *g = "UNKNOWN";
        switch (e.gesture)
        {
        case HallGesture::CLICK:
            g = "CLICK";
            break;
        case HallGesture::DOUBLE_CLICK:
            g = "DOUBLE_CLICK";
            break;
        case HallGesture::LONG_PRESS_START:
            g = "LONG_PRESS_START";
            break;
        case HallGesture::RELEASE:
            g = "RELEASE";
            break;
        }
        char buf[64];
        snprintf(buf, sizeof(buf), "[EVENT] Hall: %s (dur: %ums)\n", g, e.duration);
        Registry::getLogger().info(buf);
    }

    void onTypedEvent(const FlightStateEvent &e) override
    {
        const char *m = (e.mode == FlightMode::SETUP) ? "SETUP" : (e.mode == FlightMode::ARMED) ? "ARMED"
                                                                                                : "IN_FLIGHT";
        char buf[64];
        snprintf(buf, sizeof(buf), "[EVENT] System Mode Changed to: %s\n", m);
        Registry::getLogger().info(buf);
    }
};

EventMonitor eventMonitor;

class StatusReportTask : public ITask
{
public:
    void execute(uint32_t now) override
    {
        (void)now;
        bool wifi = network.isPowered();
        bool locked = flightService.isConfigLocked();

        char buf[128];
        snprintf(buf, sizeof(buf), ">>> STATUS: WiFi: %s | Config: %s <<<\n",
                 wifi ? "ON" : "OFF",
                 locked ? "LOCKED (Read Only)" : "UNLOCKED (Full Access)");
        Registry::getLogger().info(buf);
    }
};

StatusReportTask statusTask;

void setup()
{
    Serial.begin(115200);
    delay(1000);
    Registry::injectLogger(&asyncLogger);

    asyncLogger.info("\n=== UEF 2.0: DETAILED FSM INTEGRATION TEST ===\n");

    // Инициализация Wi-Fi
    network.setPower(true);
    WiFi.mode(WIFI_AP); // Устанавливаем режим для корректного отображения статуса

    // Подписки
    (void)globalBus.subscribe(static_cast<TypedEventListener<HallEvent> *>(&eventMonitor));
    (void)globalBus.subscribe(static_cast<TypedEventListener<FlightStateEvent> *>(&eventMonitor));
    (void)globalBus.subscribe(&flightService);

    flightService.init();

    (void)scheduler.addTask(&hallHandler, 10);
    (void)scheduler.addTask(&flightService, 20);
    (void)scheduler.addTask(&statusTask, 5000);

    asyncLogger.info("Система готова. Ожидание действий с магнитом...\n");
}

void loop()
{
    uint32_t now = millis();
    scheduler.run(now);
    asyncLogger.flush(serialSink, 512);
}