#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <ArduinoJson.h>
#include "BarometerDriver.h"
#include "KalmanFilter.h"
#include "../core/Storage.h"
#include "../config/Config.h"

namespace Sensors {
    // Переменные калибровки
    double basePressure = 0;
    double adaptiveBaseline = 0;
    double storedBasePressure = 0;  // То, что реально лежит в файле
    
    // Флаги состояния калибровки
    bool isCalibrated = false;
    bool isCalibrating = false;

    // Внешняя ссылка на состояние Калмана (определено в AltitudeCalculator)
    extern KalmanState kAlt;

    /**
     * Сохранение текущей калибровки в файл JSON
     */
    bool saveToFS() {
        if (!isCalibrated) {
            Serial.println("[Sensors] Ошибка: попытка сохранить некалиброванное значение");
            return false;
        }
        
        StaticJsonDocument<128> doc;
        doc["basePressure"] = basePressure;
        
        String output;
        serializeJson(doc, output);
        
        if (Storage::saveCalibration(output)) {
            storedBasePressure = basePressure; // Синхронизируем переменную
            Serial.print("[Sensors] Калибровка сохранена в ФС: ");
            Serial.println(storedBasePressure, 2);
            return true;
        }
        return false;
    }

    /**
     * Загрузка калибровки из файла
     */
    void loadFromFS() {
        String data = Storage::loadCalibration();
        if (data == "") {
            Serial.println("[Sensors] Файл калибровки не найден в памяти.");
            storedBasePressure = 0;
            return;
        }

        StaticJsonDocument<128> doc;
        DeserializationError error = deserializeJson(doc, data);
        
        if (!error) {
            double val = doc["basePressure"];
            if (val > 0) {
                storedBasePressure = val;
                basePressure = val;
                adaptiveBaseline = val;
                kAlt.x = 0;
                isCalibrated = true;
                Serial.print("[Sensors] Данные успешно загружены из ФС: ");
                Serial.println(storedBasePressure, 2);
            }
        } else {
            Serial.print("[Sensors] Ошибка парсинга файла калибровки: ");
            Serial.println(error.c_str());
            storedBasePressure = 0;
        }
    }

    /**
     * Полная процедура калибровки (оригинальный алгоритм)
     */
    void calibrate() {
        if (!isHardwareOK) return;
        
        isCalibrating = true;
        isCalibrated = false;
        
        Serial.println("\n[Sensors] === КОРРЕКТИРОВКА БАЗОВОГО ДАВЛЕНИЯ ===");
        Serial.println("[Sensors] Термостабилизация (10 сек)...");
        
        for (int i = 0; i < 200; i++) {
            readPressure();
            readTemperature();
            if (i % 20 == 0) Serial.print(".");
            delay(50);
        }

        Serial.println("\n[Sensors] Сбор 2000 образцов...");
        double sum = 0;
        for (int i = 0; i < 2000; i++) {
            sum += readPressure();
            if (i % 200 == 0) Serial.print(".");
            delay(5);
        }
        
        basePressure = sum / 2000.0;
        adaptiveBaseline = basePressure;
        kAlt.x = 0;
        
        isCalibrating = false;
        isCalibrated = true;
        
        Serial.print("\n[Sensors] Калибровка завершена. База: ");
        Serial.print(basePressure, 2);
        Serial.println(" Pa\n");
    }

    /**
     * Быстрая установка нуля
     */
    void zero() {
        if (!isHardwareOK) return;
        Serial.println("[Sensors] Быстрое обнуление высоты...");
        double sum = 0;
        for (int i = 0; i < 500; i++) {
            sum += readPressure();
            delay(2);
        }
        adaptiveBaseline = sum / 500.0;
        kAlt.x = 0;
        extern int stableReadings; // Определено в AltitudeCalculator
        stableReadings = 0;
        isCalibrated = true;
        Serial.print("[Sensors] Новый ноль установлен: ");
        Serial.println(adaptiveBaseline, 2);
    }
}

#endif