#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <ArduinoJson.h>
#include "BarometerDriver.h"
#include "KalmanFilter.h"
#include "../core/Storage.h"
#include "../config/Config.h"

namespace Sensors {
    // Состояния процесса калибровки
    enum CalibState {
        CALIB_IDLE,
        CALIB_WARMUP,     // Термостабилизация
        CALIB_MEASURING,  // Сбор данных (полная калибровка)
        CALIB_ZEROING     // Быстрое обнуление
    };

    // Переменные состояния
    CalibState calibState = CALIB_IDLE;
    unsigned long calibStartTime = 0;
    unsigned long lastSampleTime = 0;
    
    // Переменные накопления данных
    int samplesCollected = 0;
    const int TARGET_SAMPLES_FULL = 2000; // Для полной калибровки
    const int TARGET_SAMPLES_ZERO = 500;  // Для быстрого обнуления
    const int WARMUP_DURATION = 10000;    // Время прогрева (мс)
    double pressureSum = 0;

    // Результаты
    double basePressure = 0;
    double adaptiveBaseline = 0;
    double storedBasePressure = 0;
    
    bool isCalibrated = false;

    // Внешняя ссылка на фильтр (из AltitudeCalculator)
    extern KalmanState kAlt;
    extern int stableReadings;

    // Геттеры для StatusHandler
    int getCalibrationProgress() {
        if (calibState == CALIB_IDLE) return 0;
        
        if (calibState == CALIB_WARMUP) {
            unsigned long elapsed = millis() - calibStartTime;
            int p = (elapsed * 100) / WARMUP_DURATION;
            return constrain(p, 0, 99);
        }
        
        if (calibState == CALIB_MEASURING) {
            int p = (samplesCollected * 100) / TARGET_SAMPLES_FULL;
            return constrain(p, 0, 99);
        }

        if (calibState == CALIB_ZEROING) {
            int p = (samplesCollected * 100) / TARGET_SAMPLES_ZERO;
            return constrain(p, 0, 99);
        }
        
        return 100;
    }

    String getCalibrationPhase() {
        switch (calibState) {
            case CALIB_WARMUP: return "stabilization";
            case CALIB_MEASURING: return "measuring";
            case CALIB_ZEROING: return "zeroing";
            default: return "idle";
        }
    }

    /**
     * Запуск процесса полной калибровки (Неблокирующий)
     */
    void startCalibration() {
        if (!isHardwareOK) return;
        
        Serial.println("[Sensors] Запуск неблокирующей калибровки...");
        calibState = CALIB_WARMUP;
        calibStartTime = millis();
        lastSampleTime = millis();
        isCalibrated = false;
        pressureSum = 0;
        samplesCollected = 0;
    }

    /**
     * Запуск быстрого обнуления (Неблокирующий)
     */
    void startZeroing() {
        if (!isHardwareOK) return;

        Serial.println("[Sensors] Запуск неблокирующего обнуления...");
        calibState = CALIB_ZEROING;
        calibStartTime = millis();
        lastSampleTime = millis();
        // Не сбрасываем isCalibrated, чтобы не прыгали значения до завершения
        pressureSum = 0;
        samplesCollected = 0;
    }

    /**
     * Основной цикл машины состояний калибровки.
     * Вызывается из Sensors::update()
     */
    void updateCalibrationLogic() {
        if (calibState == CALIB_IDLE) return;

        unsigned long now = millis();

        // --- ФАЗА 1: Термостабилизация (Только для полной калибровки) ---
        if (calibState == CALIB_WARMUP) {
            if (now - lastSampleTime >= 50) {
                lastSampleTime = now;
                readPressure();
                readTemperature();
            }
            if (now - calibStartTime >= WARMUP_DURATION) {
                Serial.println("[Sensors] Термостабилизация завершена -> Сбор данных");
                calibState = CALIB_MEASURING;
                lastSampleTime = now;
                pressureSum = 0;
                samplesCollected = 0;
            }
            return;
        }

        // --- ФАЗА 2: Сбор данных (Полная калибровка) ---
        if (calibState == CALIB_MEASURING) {
            if (now - lastSampleTime >= 5) {
                lastSampleTime = now;
                pressureSum += readPressure();
                samplesCollected++;

                if (samplesCollected >= TARGET_SAMPLES_FULL) {
                    basePressure = pressureSum / (double)TARGET_SAMPLES_FULL;
                    adaptiveBaseline = basePressure;
                    kAlt.x = 0; 
                    
                    isCalibrated = true;
                    calibState = CALIB_IDLE;
                    
                    Serial.print("[Sensors] Калибровка завершена. База: ");
                    Serial.println(basePressure, 2);
                }
            }
            return;
        }

        // --- ФАЗА 3: Быстрое обнуление ---
        if (calibState == CALIB_ZEROING) {
            // Читаем без задержки (насколько позволяет датчик)
            // Сама функция readPressure() блокирует на ~26мс (стандартная библиотека),
            // но между вызовами мы возвращаем управление в loop(), поэтому сервер отвечает.
            pressureSum += readPressure();
            samplesCollected++;

            if (samplesCollected >= TARGET_SAMPLES_ZERO) {
                adaptiveBaseline = pressureSum / (double)TARGET_SAMPLES_ZERO;
                kAlt.x = 0; 
                stableReadings = 0;
                
                isCalibrated = true;
                calibState = CALIB_IDLE;
                
                Serial.print("[Sensors] Ноль установлен: ");
                Serial.println(adaptiveBaseline, 2);
            }
            return;
        }
    }

    // --- Работа с файловой системой (без изменений) ---
    bool saveToFS() {
        if (!isCalibrated) return false;
        StaticJsonDocument<128> doc;
        doc["basePressure"] = basePressure;
        String output;
        serializeJson(doc, output);
        if (Storage::saveCalibration(output)) {
            storedBasePressure = basePressure;
            Serial.print("[Sensors] Калибровка сохранена в ФС: ");
            Serial.println(storedBasePressure, 2);
            return true;
        }
        return false;
    }

    void loadFromFS() {
        String data = Storage::loadCalibration();
        if (data == "") return;
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
                Serial.println(storedBasePressure);
            }
        }
    }
}

#endif