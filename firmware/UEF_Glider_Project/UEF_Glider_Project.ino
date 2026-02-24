/**
 * UEF 2.0: ЭТАП 4 - ТЕСТ СЕРВИСА КАЛИБРОВКИ (FIXED)
 */

#include <Arduino.h>
#include <LittleFS.h>

#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/core2/engine/Scheduler.h"
#include "src/core2/messaging/EventBus.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/drivers/sensors/Bmp180.h"
#include "src/drivers/storage/FlashStorage.h"
#include "src/infrastructure/persistence/PersistenceManager.h"
#include "src/application/calibration/CalibrationService.h"

using namespace core2;
using namespace application::events;
using namespace application::calibration;

// Инфраструктура
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
EventBus<> globalBus;
Scheduler<4> scheduler;

platform::ArduinoI2c i2cBus;
drivers::Bmp180 bmp(i2cBus);

drivers::FlashStorage flashDriver;
infrastructure::persistence::PersistenceManager persistence(flashDriver);

// Сервис
CalibrationService calibService(bmp, persistence, globalBus);

class CalibMonitor : public TypedEventListener<CalibrationEvent>
{
public:
    void onTypedEvent(const CalibrationEvent &e) override
    {
        char buf[64];
        switch (e.status)
        {
        case CalibrationStatus::WARMUP:
            snprintf(buf, sizeof(buf), "CALIB: Прогрев... %u%%\n", e.progress);
            break;
        case CalibrationStatus::MEASURING:
            snprintf(buf, sizeof(buf), "CALIB: Замер давления... %u%%\n", e.progress);
            break;
        case CalibrationStatus::ZEROING:
            snprintf(buf, sizeof(buf), "CALIB: Обнуление... %u%%\n", e.progress);
            break;
        case CalibrationStatus::SUCCESS:
            snprintf(buf, sizeof(buf), "CALIB: УСПЕХ! База: %.1f Па\n", calibService.getLastResult().basePressure);
            break;
        case CalibrationStatus::IDLE:
            return;
        default:
            break;
        }
        Registry::getLogger().info(buf);
    }
};

CalibMonitor monitor;

void setup()
{
    Serial.begin(config::DEFAULT_HW_MAP.baudRate);
    delay(1000);

    Registry::injectLogger(&asyncLogger);

    if (!LittleFS.begin())
    {
        asyncLogger.error("FS Mount Fail\n");
    }

    i2cBus.init(config::DEFAULT_HW_MAP.pinI2cSda, config::DEFAULT_HW_MAP.pinI2cScl);

    if (!bmp.begin().isOk())
    {
        asyncLogger.error("BMP180 не найден!\n");
    }

    globalBus.subscribe(&monitor);

    // Исправлено: обработка возвращаемого значения addTask
    if (!scheduler.addTask(&calibService, 5))
    {
        asyncLogger.error("Ошибка: не удалось добавить задачу калибровки\n");
    }

    asyncLogger.info("\n--- UEF 2.0 Stage 4: Calibration Service (Fixed) ---\n");
    asyncLogger.info("Команды: 'c' - калибровка, 'z' - обнуление, 's' - сохранить\n");
}

void loop()
{
    uint32_t now = millis();
    scheduler.run(now);

    if (Serial.available() > 0)
    {
        char cmd = Serial.read();
        if (cmd == 'c')
            calibService.startFull();
        else if (cmd == 'z')
            calibService.startZero();
        else if (cmd == 's')
        {
            if (calibService.saveToStorage().isOk())
                asyncLogger.info("Сохранено\n");
            else
                asyncLogger.error("Ошибка сохранения\n");
        }
    }

    asyncLogger.flush(serialSink, 256);
}