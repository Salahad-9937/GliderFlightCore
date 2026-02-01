#ifndef STORAGE_H
#define STORAGE_H

#include <LittleFS.h>
#include "../config/Config.h"

namespace Storage
{
    /**
     * Инициализация файловой системы
     */
    void begin()
    {
        if (!LittleFS.begin())
        {
            Serial.println("[FS] FAILED to mount file system. Halting.");
            while (1)
                delay(100);
        }
        Serial.println("[FS] File system mounted successfully.");
    }

    /**
     * Вспомогательный метод для записи файлов с полным логированием (DRY)
     */
    bool writeFile(const char *path, const String &data, const char *logTag)
    {
        File file = LittleFS.open(path, "w");
        if (!file)
        {
            Serial.printf("[FS] Failed to open %s for writing!\n", path);
            return false;
        }
        size_t bytesWritten = file.print(data);
        file.close();

        if (bytesWritten > 0)
        {
            if (logTag)
            {
                Serial.printf("[FS] %s saved. Bytes written: %d\n", logTag, bytesWritten);
            }
            return true;
        }
        else
        {
            Serial.printf("[FS] Error: Written 0 bytes to %s!\n", path);
            return false;
        }
    }

    // --- Работа с пинами ---

    void loadPins(Config::PinConfig &p)
    {
        if (!LittleFS.exists(PINS_FILE))
        {
            Serial.println("[FS] Pins config not found. Using defaults.");
            p.loadDefaults();
            return;
        }

        File file = LittleFS.open(PINS_FILE, "r");
        if (!file)
            return;
        String json = file.readString();
        file.close();

        if (p.deserialize(json))
        {
            Serial.println("[FS] Pins config loaded from LittleFS.");
        }
    }

    bool savePins(const Config::PinConfig &p)
    {
        return writeFile(PINS_FILE, p.serialize(), "Pins config");
    }

    // --- Работа с программой и калибровкой ---

    bool saveProgram(String json)
    {
        return writeFile("/program.json", json, "Program");
    }

    bool saveCalibration(String json)
    {
        // Для калибровки используем оригинальный краткий лог из ТЗ
        File file = LittleFS.open(CALIB_FILE, "w");
        if (!file)
        {
            Serial.println("[FS] Failed to open calib file for writing");
            return false;
        }
        size_t bytes = file.print(json);
        file.close();
        return bytes > 0;
    }

    String loadCalibration()
    {
        if (!LittleFS.exists(CALIB_FILE))
            return "";
        File file = LittleFS.open(CALIB_FILE, "r");
        if (!file)
            return "";
        String data = file.readString();
        file.close();
        return data;
    }
}
#endif