#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <ArduinoJson.h>
#include "BarometerDriver.h"
#include "KalmanFilter.h"
#include "../core/Storage.h"
#include "../config/Config.h"

namespace Sensors
{
    // Предварительное объявление для доступа к sys
    struct SystemStatus;
    extern SystemStatus sys;

    enum CalibState
    {
        CALIB_IDLE,
        CALIB_WARMUP,
        CALIB_MEASURING,
        CALIB_ZEROING
    };

    struct CalibrationSession
    {
        unsigned long startTime = 0;
        int samplesCollected = 0;
        double pressureSum = 0;
        const int targetFull = 2000;
        const int targetZero = 500;
        const int warmupMs = 10000;
    };

    CalibState calibState = CALIB_IDLE;
    CalibrationSession session;
    unsigned long lastSampleTime = 0;

    double basePressure = 0;
    double adaptiveBaseline = 0;
    double storedBasePressure = 0;

    extern KalmanState kAlt;
    extern int stableReadings;

    // --- Вспомогательные методы ---

    void handleWarmupPhase(unsigned long now)
    {
        if (now - lastSampleTime >= 50)
        {
            lastSampleTime = now;
            readPressure();
            readTemperature();
        }
        if (now - session.startTime >= session.warmupMs)
        {
            Serial.println("[Sensors] Термостабилизация завершена -> Сбор данных");
            calibState = CALIB_MEASURING;
            lastSampleTime = now;
            session.pressureSum = 0;
            session.samplesCollected = 0;
        }
    }

    void handleMeasuringPhase(unsigned long now)
    {
        if (now - lastSampleTime >= 5)
        {
            lastSampleTime = now;
            session.pressureSum += readPressure();
            session.samplesCollected++;

            if (session.samplesCollected >= session.targetFull)
            {
                basePressure = session.pressureSum / (double)session.targetFull;
                adaptiveBaseline = basePressure;
                kAlt.x = 0;
                sys.calibrated = true;
                calibState = CALIB_IDLE;

                Serial.print("[Sensors] Калибровка завершена. База: ");
                Serial.println(basePressure, 2);
            }
        }
    }

    void handleZeroingPhase()
    {
        session.pressureSum += readPressure();
        session.samplesCollected++;

        if (session.samplesCollected >= session.targetZero)
        {
            adaptiveBaseline = session.pressureSum / (double)session.targetZero;
            kAlt.x = 0;
            stableReadings = 0;
            sys.calibrated = true;
            calibState = CALIB_IDLE;

            Serial.print("[Sensors] Ноль установлен: ");
            Serial.println(adaptiveBaseline, 2);
        }
    }

    // --- Публичный интерфейс ---

    int getCalibrationProgress()
    {
        if (calibState == CALIB_IDLE)
            return 0;
        if (calibState == CALIB_WARMUP)
        {
            unsigned long elapsed = millis() - session.startTime;
            return constrain((elapsed * 100) / session.warmupMs, 0, 99);
        }
        if (calibState == CALIB_MEASURING)
        {
            return constrain((session.samplesCollected * 100) / session.targetFull, 0, 99);
        }
        if (calibState == CALIB_ZEROING)
        {
            return constrain((session.samplesCollected * 100) / session.targetZero, 0, 99);
        }
        return 100;
    }

    String getCalibrationPhase()
    {
        switch (calibState)
        {
        case CALIB_WARMUP:
            return "stabilization";
        case CALIB_MEASURING:
            return "measuring";
        case CALIB_ZEROING:
            return "zeroing";
        default:
            return "idle";
        }
    }

    void startCalibration()
    {
        if (!sys.hardwareOK)
            return;
        Serial.println("[Sensors] Запуск неблокирующей калибровки...");
        calibState = CALIB_WARMUP;
        session.startTime = millis();
        lastSampleTime = millis();
        sys.calibrated = false;
        session.pressureSum = 0;
        session.samplesCollected = 0;
    }

    void startZeroing()
    {
        if (!sys.hardwareOK)
            return;
        Serial.println("[Sensors] Запуск неблокирующего обнуления...");
        calibState = CALIB_ZEROING;
        session.startTime = millis();
        lastSampleTime = millis();
        session.pressureSum = 0;
        session.samplesCollected = 0;
    }

    void cancel()
    {
        if (calibState == CALIB_IDLE)
            return;
        Serial.println("[Sensors] Операция прервана пользователем!");
        calibState = CALIB_IDLE;
        session.pressureSum = 0;
        session.samplesCollected = 0;
    }

    void updateCalibrationLogic()
    {
        if (calibState == CALIB_IDLE)
            return;
        unsigned long now = millis();

        if (calibState == CALIB_WARMUP)
            handleWarmupPhase(now);
        else if (calibState == CALIB_MEASURING)
            handleMeasuringPhase(now);
        else if (calibState == CALIB_ZEROING)
            handleZeroingPhase();
    }

    bool saveToFS()
    {
        if (!sys.calibrated)
            return false;
        StaticJsonDocument<128> doc;
        doc["basePressure"] = basePressure;
        String output;
        serializeJson(doc, output);
        if (Storage::saveCalibration(output))
        {
            storedBasePressure = basePressure;
            Serial.print("[Sensors] Калибровка сохранена в ФС: ");
            Serial.println(storedBasePressure, 2);
            return true;
        }
        return false;
    }

    void loadFromFS()
    {
        String data = Storage::loadCalibration();
        if (data == "")
            return;
        StaticJsonDocument<128> doc;
        if (!deserializeJson(doc, data))
        {
            double val = doc["basePressure"];
            if (val > 0)
            {
                storedBasePressure = val;
                basePressure = val;
                adaptiveBaseline = val;
                kAlt.x = 0;
                sys.calibrated = true;
                Serial.print("[Sensors] Данные успешно загружены из ФС: ");
                Serial.println(storedBasePressure);
            }
        }
    }
}
#endif