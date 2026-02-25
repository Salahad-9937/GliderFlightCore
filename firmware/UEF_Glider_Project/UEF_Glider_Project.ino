/**
 * UEF 2.0: ТЕСТ СЕРВИСОВ ТЕЛЕМЕТРИИ И КАЛИБРОВКИ
 *
 * Проверка интеграции:
 * HAL (Adafruit) -> Driver (Bmp180) -> Services (Telemetry/Calibration)
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
#include "src/application/events/CalibrationEvents.h"

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
platform::Esp8266Barometer baroHal;
drivers::Bmp180 bmp(baroHal);

drivers::FlashStorage flashDriver;
PersistenceManager persistence(flashDriver);

// --- СЕРВИСЫ ---
TelemetryService telemetry(bmp);
CalibrationService calibService(bmp, persistence, globalBus);

// --- МОНИТОРИНГ СОБЫТИЙ ---
class CalibrationMonitor : public TypedEventListener<CalibrationEvent>
{
public:
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
            Registry::getLogger().info("[CALIB] УСПЕХ! Новое давление применено.\n");
            // Обновляем базу в телеметрии сразу после успеха
            telemetry.setBasePressure(calibService.getLastResult().basePressure);
            break;
        case CalibrationStatus::ERROR:
            Registry::getLogger().error("[CALIB] ОШИБКА ОБОРУДОВАНИЯ!\n");
            break;
        default:
            break;
        }
    }
};

CalibrationMonitor calibMonitor;

// Задача для вывода данных в Serial
class LogTask : public ITask
{
public:
    void execute(uint32_t now) override
    {
        (void)now;
        // Не мешаем логам калибровки, если она идет
        if (calibService.getStatus() != CalibrationStatus::IDLE)
            return;

        const auto &data = telemetry.getData();
        char buf[128];
        snprintf(buf, sizeof(buf),
                 "TELEMETRY: Alt: %.2fм | P: %.0fПа | T: %.1fC | Stable: %s\n",
                 data.altitude, data.pressure, data.temperature,
                 data.isStable ? "YES" : "NO");
        Registry::getLogger().info(buf);
    }
};

LogTask logTask;

void setup()
{
    Serial.begin(115200);
    delay(1000);
    Registry::injectLogger(&asyncLogger);

    asyncLogger.info("\n=== UEF 2.0: SERVICE INTEGRATION TEST ===\n");

    if (!LittleFS.begin())
        asyncLogger.error("FS: Ошибка LittleFS\n");

    // 1. Инициализация I2C и сервиса телеметрии
    i2cBus.init(config::DEFAULT_HW_MAP.pinI2cSda, config::DEFAULT_HW_MAP.pinI2cScl);

    if (telemetry.begin().isOk())
    {
        asyncLogger.info("HW: BMP180 инициализирован через TelemetryService\n");
    }
    else
    {
        asyncLogger.error("HW: Ошибка инициализации BMP180\n");
    }

    // 2. Загрузка сохраненной калибровки
    CalibrationProfile saved;
    if (persistence.load(StorageKey::CALIBRATION, saved).isOk())
    {
        asyncLogger.info("FS: Калибровка восстановлена из памяти\n");
        telemetry.setBasePressure(saved.basePressure);
    }

    // 3. Подписки и задачи
    (void)globalBus.subscribe(&calibMonitor);

    (void)scheduler.addTask(&telemetry, 5);    // Опрос датчика каждые 5мс
    (void)scheduler.addTask(&calibService, 5); // Логика калибровки каждые 5мс
    (void)scheduler.addTask(&logTask, 1000);   // Вывод в лог раз в секунду

    asyncLogger.info("Команды: 'c'-Full Calib, 'z'-Zero, 's'-Save to Flash\n");
}

void loop()
{
    uint32_t now = millis();
    scheduler.run(now);

    // Обработка команд
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
                asyncLogger.info("FS: Сохранено\n");
            else
                asyncLogger.error("FS: Ошибка сохранения\n");
        }
    }

    asyncLogger.flush(serialSink, 256);
}