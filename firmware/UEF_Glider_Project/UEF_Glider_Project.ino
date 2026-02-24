/**
 * UEF 2.0: ЭТАП 3 - ВЕРИФИКАЦИЯ ХРАНИЛИЩА И CRC16
 */

#include <Arduino.h>
#include <LittleFS.h>

#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/drivers/storage/FlashStorage.h"
#include "src/domain/telemetry/CalibrationProfile.h"
#include "src/infrastructure/persistence/PersistenceManager.h"

using namespace core2;
using namespace domain::telemetry;
using namespace infrastructure::persistence;

// Инфраструктура
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
drivers::FlashStorage flashDriver;
PersistenceManager persistence(flashDriver);

void forceFlush()
{
    asyncLogger.flush(serialSink, 2048);
}

void setup()
{
    Serial.begin(config::DEFAULT_HW_MAP.baudRate);
    delay(2000);

    Registry::injectLogger(&asyncLogger);
    asyncLogger.info("\n=== ТЕСТ СЛОЯ PERSISTENCE ===\n");

    if (!LittleFS.begin())
    {
        asyncLogger.error("КРИТИЧЕСКАЯ ОШИБКА: LittleFS не смонтирован\n");
        forceFlush();
        return;
    }

    // --- ТЕСТ 1: Чтение пустых данных ---
    asyncLogger.info("[1/4] Проверка загрузки при отсутствии файла... ");
    LittleFS.remove("/f_100.bin"); // Удаляем файл калибровки (Key 100)

    CalibrationProfile testProfile;
    auto status = persistence.load(StorageKey::CALIBRATION, testProfile);
    if (status.error() == ErrorCode::NOT_FOUND)
    {
        asyncLogger.info("OK (Файл отсутствует, как и ожидалось)\n");
    }
    else
    {
        asyncLogger.error("FAIL (Неверный код ошибки)\n");
    }
    forceFlush();

    // --- ТЕСТ 2: Запись и чтение ---
    asyncLogger.info("[2/4] Запись данных и проверка целостности... ");
    testProfile.basePressure = 101325.5f;
    testProfile.timestamp = 12345678;
    testProfile.isValid = true;

    if (persistence.save(StorageKey::CALIBRATION, testProfile).isOk())
    {
        CalibrationProfile restoredProfile;
        if (persistence.load(StorageKey::CALIBRATION, restoredProfile).isOk())
        {
            if (restoredProfile.basePressure == testProfile.basePressure &&
                restoredProfile.timestamp == testProfile.timestamp)
            {
                asyncLogger.info("OK (Данные идентичны)\n");
            }
            else
            {
                asyncLogger.error("FAIL (Данные искажены при чтении)\n");
            }
        }
        else
        {
            asyncLogger.error("FAIL (Ошибка загрузки после сохранения)\n");
        }
    }
    else
    {
        asyncLogger.error("FAIL (Ошибка сохранения)\n");
    }
    forceFlush();

    // --- ТЕСТ 3: Защита от повреждения (CRC16) ---
    asyncLogger.info("[3/4] Имитация повреждения файла (тест CRC)... ");
    // Открываем файл напрямую через LittleFS и портим один байт данных
    File f = LittleFS.open("/f_100.bin", "r+");
    if (f)
    {
        f.seek(4); // Смещение внутрь payload
        f.write(0xFF);
        f.close();

        CalibrationProfile corruptedProfile;
        status = persistence.load(StorageKey::CALIBRATION, corruptedProfile);
        if (status.error() == ErrorCode::INVALID_ARGUMENT)
        {
            asyncLogger.info("OK (Обнаружено повреждение CRC)\n");
        }
        else
        {
            asyncLogger.error("FAIL (Менеджер пропустил битые данные!)\n");
        }
    }
    else
    {
        asyncLogger.error("FAIL (Не удалось открыть файл для порчи)\n");
    }
    forceFlush();

    // --- ТЕСТ 4: Восстановление ---
    asyncLogger.info("[4/4] Перезапись поврежденных данных... ");
    testProfile.basePressure = 99800.0f;
    if (persistence.save(StorageKey::CALIBRATION, testProfile).isOk())
    {
        asyncLogger.info("OK (Файл исправлен)\n");
    }
    else
    {
        asyncLogger.error("FAIL\n");
    }

    asyncLogger.info("=== ТЕСТ ЗАВЕРШЕН ===\n");
    forceFlush();
}

void loop()
{
    // Пустой цикл
}