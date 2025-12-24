#ifndef STORAGE_H
#define STORAGE_H

#include <LittleFS.h>

namespace Storage {
    /**
     * Инициализация файловой системы
     */
    void begin() {
        if (!LittleFS.begin()) {
            Serial.println("[FS] FAILED to mount file system. Halting.");
            while(1) delay(100);
        }
        Serial.println("[FS] File system mounted successfully.");
    }

    /**
     * Сохранение полетной программы
     */
    bool saveProgram(String json) {
        File file = LittleFS.open("/program.json", "w");
        if (!file) {
            Serial.println("[FS] Failed to open /program.json for writing!");
            return false;
        }
        size_t bytesWritten = file.print(json);
        file.close();
        
        if (bytesWritten > 0) {
            Serial.print("[FS] Program saved. Bytes written: ");
            Serial.println(bytesWritten);
            return true;
        } else {
            Serial.println("[FS] Error: Written 0 bytes!");
            return false;
        }
    }

    /**
     * Сохранение данных калибровки
     */
    bool saveCalibration(String json) {
        File file = LittleFS.open(CALIB_FILE, "w");
        if (!file) {
            Serial.println("[FS] Failed to open calib file for writing");
            return false;
        }
        size_t bytes = file.print(json);
        file.close();
        return bytes > 0;
    }

    /**
     * Загрузка данных калибровки
     */
    String loadCalibration() {
        if (!LittleFS.exists(CALIB_FILE)) return "";
        File file = LittleFS.open(CALIB_FILE, "r");
        if (!file) return "";
        String data = file.readString();
        file.close();
        return data;
    }
}
#endif