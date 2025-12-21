#ifndef STORAGE_H
#define STORAGE_H

#include <LittleFS.h>

namespace Storage {
    void begin() {
        if (!LittleFS.begin()) {
            Serial.println("[FS] FAILED to mount file system. Halting.");
            while(1) delay(100);
        }
        Serial.println("[FS] File system mounted successfully.");
    }

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
}
#endif