/**
 * UEF 2.0: ТЕСТ ЭТАПА 1 (DOMAIN & PERSISTENCE)
 *
 * Проверка:
 * 1. Создание доменной модели FlightProgram.
 * 2. Сохранение через PersistenceManager (расчет CRC16).
 * 3. Загрузка через ProgramManager (проверка CRC16).
 */

#include <Arduino.h>
#include <LittleFS.h>

#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/core2/engine/Scheduler.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/drivers/storage/FlashStorage.h"
#include "src/infrastructure/persistence/PersistenceManager.h"
#include "src/application/flight/ProgramManager.h"

using namespace core2;
using namespace infrastructure::persistence;
using namespace application::flight;
using namespace domain::flight;

// --- ИНФРАСТРУКТУРА ---
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
Scheduler<4> scheduler;

drivers::FlashStorage flashDriver;
PersistenceManager persistence(flashDriver);

// --- СЕРВИСЫ ---
ProgramManager programManager(persistence);

/**
 * @brief Функция имитации получения программы по сети (Mock).
 */
auto mockIncomingProgram() -> FlightProgram
{
    FlightProgram p;
    strncpy(p.id, "550e8400-e29b-41d4-a716-446655440000", ID_MAX_LEN);
    strncpy(p.name, "Термик-Актив", NAME_MAX_LEN);

    p.stepsCount = 3;
    // Шаг 1: Руль вправо на 20 градусов, 2.5 сек
    p.steps[0] = {20, 2500};
    // Шаг 2: Руль влево на 10 градусов, 5 сек
    p.steps[1] = {-10, 5000};
    // Шаг 3: Нейтраль, 10 сек
    p.steps[2] = {0, 10000};

    return p;
}

/**
 * @brief Тестовая задача для верификации данных.
 */
void runPersistenceTest()
{
    asyncLogger.info("\n>>> ЗАПУСК ТЕСТА PERSISTENCE <<<\n");

    // 1. Создаем мок-программу
    FlightProgram original = mockIncomingProgram();
    asyncLogger.info("TEST: Подготовка мок-программы...\n");

    // 2. Сохраняем
    if (programManager.saveProgram(original).isOk())
    {
        asyncLogger.info("TEST: Программа сохранена с CRC16.\n");
    }
    else
    {
        asyncLogger.error("TEST: Ошибка сохранения!\n");
    }

    // 3. Пытаемся загрузить в новый объект
    if (programManager.loadActiveProgram().isOk())
    {
        const auto &loaded = programManager.getActiveProgram();

        char buf[128];
        snprintf(buf, sizeof(buf), "TEST: Загружено: [%s] '%s', Шагов: %u\n",
                 loaded.id, loaded.name, loaded.stepsCount);
        asyncLogger.info(buf);

        // Проверка целостности данных шагов
        if (loaded.steps[0].durationMs == 2500 && loaded.steps[1].value == -10)
        {
            asyncLogger.info("TEST: ВЕРИФИКАЦИЯ ДАННЫХ ПРОЙДЕНА (Match OK).\n");
        }
        else
        {
            asyncLogger.error("TEST: ДАННЫЕ ИСКАЖЕНЫ!\n");
        }
    }
    else
    {
        asyncLogger.error("TEST: Ошибка загрузки или CRC!\n");
    }
}

void setup()
{
    Serial.begin(115200);
    delay(1000);
    Registry::injectLogger(&asyncLogger);

    asyncLogger.info("\n=== UEF 2.0: STAGE 1 TEST (FLIGHT PROGRAM) ===\n");

    if (!LittleFS.begin())
    {
        asyncLogger.error("FS: Ошибка LittleFS\n");
        return;
    }

    // Запуск теста
    runPersistenceTest();
}

void loop()
{
    uint32_t now = millis();
    scheduler.run(now);

    // Команда для повторного теста
    if (Serial.available() > 0)
    {
        char cmd = (char)Serial.read();
        if (cmd == 't')
            runPersistenceTest();
    }

    asyncLogger.flush(serialSink, 512);
}