/**
 * UEF 2.0: КОМПЛЕКСНЫЙ ТЕСТ БИЗНЕС-ЛОГИКИ (V2)
 *
 * ПРАВИЛА ТЕСТИРОВАНИЯ:
 * 1. Датчик Холла (Магнит):
 *    - Клик: Включить светодиод (LED ON).
 *    - Двойной клик: Выключить светодиод (LED OFF).
 *    - Удержание (3 сек): Просто лог "LONG PRESS" (без запуска калибровки!).
 *
 * 2. Калибровка (Serial Terminal):
 *    - Отправь 'c': Полная калибровка (10с прогрев + 2000 замеров).
 *    - Отправь 'z': Быстрое обнуление (500 замеров).
 *    - Отправь 's': Сохранить результат во Flash.
 *
 * 3. Телеметрия:
 *    - Выводится в лог раз в секунду, если не идет калибровка.
 */

#include <Arduino.h>
#include <LittleFS.h>

#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/core2/messaging/EventBus.h"
#include "src/core2/messaging/EventListener.h"
#include "src/core2/engine/Scheduler.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/drivers/sensors/Bmp180.h"
#include "src/drivers/storage/FlashStorage.h"
#include "src/infrastructure/persistence/PersistenceManager.h"
#include "src/application/telemetry/TelemetryService.h"
#include "src/application/calibration/CalibrationService.h"
#include "src/application/events/InputEvents.h"
#include "src/application/events/CalibrationEvents.h"
#include "src/presentation/input/HallSensorHandler.h"

using namespace core2;
using namespace application::events;
using namespace application::telemetry;
using namespace application::calibration;
using namespace infrastructure::persistence;

// --- ИНФРАСТРУКТУРА ---
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
EventBus<> globalBus;
Scheduler<8> scheduler;

platform::ArduinoI2c i2cBus;
platform::DigitalInput hallPin(config::DEFAULT_HW_MAP.pinHall);
platform::DigitalOutput ledPin(config::DEFAULT_HW_MAP.pinLed1);

drivers::Bmp180 bmp(i2cBus);
drivers::FlashStorage flashDriver;
PersistenceManager persistence(flashDriver);

// --- СЕРВИСЫ ---
TelemetryService telemetry(bmp);
CalibrationService calibService(bmp, persistence, globalBus);
presentation::input::HallSensorHandler hallHandler(hallPin, globalBus);

// --- МОНИТОРИНГ ---
class SystemMonitor : public TypedEventListener<HallEvent>,
                      public TypedEventListener<CalibrationEvent>
{
public:
    void onTypedEvent(const HallEvent &e) override
    {
        switch (e.gesture)
        {
        case HallGesture::CLICK:
            Registry::getLogger().info("[HALL] Клик -> LED ON\n");
            (void)ledPin.write(true);
            break;
        case HallGesture::DOUBLE_CLICK:
            Registry::getLogger().info("[HALL] Двойной клик -> LED OFF\n");
            (void)ledPin.write(false);
            break;
        case HallGesture::LONG_PRESS_START:
            Registry::getLogger().info("[HALL] Удержание зафиксировано (Long Press)\n");
            break;
        case HallGesture::RELEASE:
            // Просто фиксируем факт ухода магнита
            break;
        }
    }

    void onTypedEvent(const CalibrationEvent &e) override
    {
        char buf[64];
        switch (e.status)
        {
        case CalibrationStatus::WARMUP:
            snprintf(buf, sizeof(buf), "[CALIB] Прогрев: %u%%\n", e.progress);
            Registry::getLogger().info(buf);
            break;
        case CalibrationStatus::MEASURING:
            snprintf(buf, sizeof(buf), "[CALIB] Сбор данных: %u%%\n", e.progress);
            Registry::getLogger().info(buf);
            break;
        case CalibrationStatus::ZEROING:
            snprintf(buf, sizeof(buf), "[CALIB] Обнуление: %u%%\n", e.progress);
            Registry::getLogger().info(buf);
            break;
        case CalibrationStatus::SUCCESS:
            Registry::getLogger().info("[CALIB] УСПЕХ! Новая база применена.\n");
            telemetry.setBasePressure(calibService.getLastResult().basePressure);
            break;
        default:
            break;
        }
    }
};

SystemMonitor sysMonitor;

class TelemetryLogTask : public ITask
{
public:
    void execute(uint32_t now) override
    {
        (void)now;
        // Не выводим телеметрию, пока датчик занят калибровкой
        if (calibService.getStatus() != CalibrationStatus::IDLE)
            return;

        const auto &data = telemetry.getData();
        char buf[128];
        snprintf(buf, sizeof(buf),
                 "DATA: Alt: %.2fм | P: %.0fПа | T: %.1fC | Stable: %s\n",
                 data.altitude, data.pressure, data.temperature,
                 data.isStable ? "YES" : "NO");
        Registry::getLogger().info(buf);
    }
};

TelemetryLogTask telemetryLogTask;

// --- SETUP ---
void setup()
{
    Serial.begin(config::DEFAULT_HW_MAP.baudRate);
    delay(1000);
    Registry::injectLogger(&asyncLogger);

    asyncLogger.info("\n=== UEF 2.0: ТЕСТ БИЗНЕС-ЛОГИКИ (V2) ===\n");

    if (!LittleFS.begin())
        asyncLogger.error("FS: Ошибка LittleFS\n");

    i2cBus.init(config::DEFAULT_HW_MAP.pinI2cSda, config::DEFAULT_HW_MAP.pinI2cScl);
    if (!telemetry.begin().isOk())
        asyncLogger.error("HW: BMP180 не найден\n");

    // Загрузка старой калибровки
    CalibrationProfile saved;
    if (persistence.load(StorageKey::CALIBRATION, saved).isOk())
    {
        asyncLogger.info("FS: Калибровка восстановлена из памяти.\n");
        telemetry.setBasePressure(saved.basePressure);
    }

    // Подписки
    (void)globalBus.subscribe(static_cast<TypedEventListener<HallEvent> *>(&sysMonitor));
    (void)globalBus.subscribe(static_cast<TypedEventListener<CalibrationEvent> *>(&sysMonitor));

    // Задачи
    (void)scheduler.addTask(&hallHandler, 10);
    (void)scheduler.addTask(&telemetry, 5);
    (void)scheduler.addTask(&calibService, 5);
    (void)scheduler.addTask(&telemetryLogTask, 1000);

    asyncLogger.info("ГОТОВО. Команды Serial: 'c'-Calib, 'z'-Zero, 's'-Save\n");
}

void loop()
{
    uint32_t now = millis();
    scheduler.run(now);

    if (Serial.available() > 0)
    {
        char cmd = (char)Serial.read();
        if (cmd == 'c')
            calibService.startFull();
        else if (cmd == 'z')
            calibService.startZero();
        else if (cmd == 's')
        {
            if (calibService.saveToStorage().isOk())
                asyncLogger.info("Результат сохранен.\n");
            else
                asyncLogger.error("Нет данных для сохранения.\n");
        }
    }

    asyncLogger.flush(serialSink, 256);
}