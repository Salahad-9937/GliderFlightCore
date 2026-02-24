/**
 * UEF 2.0: ТЕСТ ХРАНИЛИЩА
 */

#include <Arduino.h>
#include <LittleFS.h>

#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/drivers/storage/FlashStorage.h"

using namespace core2;

struct FlightConfig
{
    uint32_t flightId;
    float basePressure;
    uint8_t servoTrim;
    char pilotName[16];
};

platform::SerialSink serialSink;
BufferedLogger asyncLogger;
drivers::FlashStorage storage;

void forceFlush()
{
    asyncLogger.flush(serialSink, 1024);
}

void setup()
{
    Serial.begin(config::DEFAULT_HW_MAP.baudRate);
    delay(2000);

    Registry::injectLogger(&asyncLogger);

    asyncLogger.info("\n=======================================\n");
    asyncLogger.info("   UEF 2.0: STORAGE TEST       \n");
    asyncLogger.info("=======================================\n");
    forceFlush();

    asyncLogger.info("[1/6] Монтирование LittleFS... ");
    if (LittleFS.begin())
    {
        asyncLogger.info("FS Mount: OK\n");
    }
    else
    {
        asyncLogger.error("FS Mount: FAIL\n");
        asyncLogger.error("!!! Проверьте настройки Flash Size в IDE !!!\n");
        forceFlush();
        return;
    }
    forceFlush();

    uint16_t fileKey = 1001;
    FlightConfig original = {0xDEADBEEF, 101325.0f, 90, "TEST_PILOT"};
    FlightConfig restored = {0, 0.0f, 0, ""};
    char buf[128];

    asyncLogger.info("[2/6] Сохранение структуры (STORE)... ");
    if (storage.store(fileKey, &original, sizeof(original)).isOk())
    {
        asyncLogger.info("OK\n");
    }
    else
    {
        asyncLogger.error("WRITE ERROR\n");
        return;
    }
    forceFlush();

    asyncLogger.info("[3/6] Чтение данных обратно (LOAD)... ");
    if (storage.load(fileKey, &restored, sizeof(restored)).isOk())
    {
        asyncLogger.info("OK\n");
    }
    else
    {
        asyncLogger.error("READ ERROR\n");
        return;
    }
    forceFlush();

    asyncLogger.info("[4/6] Проверка содержимого:\n");
    snprintf(buf, sizeof(buf), "   - Flight ID: 0x%X (Expect: 0x%X)\n", restored.flightId, original.flightId);
    asyncLogger.info(buf);
    
    // Сверка памяти
    if (memcmp(&original, &restored, sizeof(FlightConfig)) == 0)
    {
        asyncLogger.info("   -> Binary Match: YES\n");
    }
    else
    {
        asyncLogger.error("   -> Binary Match: NO\n");
    }
    forceFlush();

    // --- ТЕСТ APPEND ---
    asyncLogger.info("[5/6] Тест дозаписи (APPEND)... \n");
    uint16_t logKey = 2002;
    const char* part1 = "Hello";
    const char* part2 = " World";
    char resultBuf[12] = {0}; // 5 + 6 + 1 null

    storage.store(logKey, part1, 5); // Пишем "Hello"
    storage.append(logKey, part2, 6); // Дописываем " World"
    
    asyncLogger.info("   -> Data written. Reading back... ");
    
    if (storage.load(logKey, resultBuf, 11).isOk()) {
        asyncLogger.info("OK\n");
        snprintf(buf, sizeof(buf), "   -> Result: '%s'\n", resultBuf);
        asyncLogger.info(buf);
        
        if (strcmp(resultBuf, "Hello World") == 0) {
             asyncLogger.info("[6/6] Append Verification: SUCCESS\n");
        } else {
             asyncLogger.info("[6/6] Append Verification: FAIL\n");
        }
    } else {
        asyncLogger.error("READ ERROR\n");
    }

    asyncLogger.info("=======================================\n");
    forceFlush();
}

void loop() {}