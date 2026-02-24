/**
 * UEF 2.0: ЭТАП 2 - ТЕСТ ТЕЛЕМЕТРИИ
 */

#include <Arduino.h>
#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/core2/engine/Scheduler.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/drivers/sensors/Bmp180.h"
#include "src/application/telemetry/TelemetryService.h"

using namespace core2;

// Инфраструктура
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
platform::ArduinoI2c i2cBus;
Scheduler<4> scheduler;

// Драйверы и Сервисы
drivers::Bmp180 bmp(i2cBus);
application::telemetry::TelemetryService telemetry(bmp);

/**
 * Задача для вывода данных в лог.
 */
class LogTask : public ITask
{
public:
    void execute(uint32_t now) override
    {
        auto data = telemetry.getData();
        char buf[128];
        snprintf(buf, sizeof(buf),
                 "TELEMETRY: Alt: %.2fm | Temp: %.1fC | P: %.0fPa | Stable: %s\n",
                 data.altitude, data.temperature, data.pressure,
                 data.isStable ? "YES" : "NO");
        Registry::getLogger().info(buf);
    }
};

LogTask loggerTask;

void setup()
{
    Serial.begin(config::DEFAULT_HW_MAP.baudRate);
    delay(1000);

    Registry::injectLogger(&asyncLogger);
    asyncLogger.info("--- UEF 2.0 Stage 2: Telemetry Test ---\n");

    // Инициализация I2C
    i2cBus.init(config::DEFAULT_HW_MAP.pinI2cSda, config::DEFAULT_HW_MAP.pinI2cScl);

    // Инициализация сервиса
    if (telemetry.begin().isOk())
    {
        asyncLogger.info("BMP180: OK\n");
        // Установим текущее давление как базовое для теста (обнуление)
        // В реальном приложении это будет делать сервис калибровки
        telemetry.execute(millis());
        telemetry.setBasePressure(telemetry.getData().pressure);
    }
    else
    {
        asyncLogger.error("BMP180: FAIL\n");
    }

    // Настройка планировщика
    scheduler.addTask(&telemetry, 100);   // Опрос датчика 10 раз в секунду
    scheduler.addTask(&loggerTask, 1000); // Вывод в лог раз в секунду
}

void loop()
{
    uint32_t now = millis();
    scheduler.run(now);
    asyncLogger.flush(serialSink, 256);
}