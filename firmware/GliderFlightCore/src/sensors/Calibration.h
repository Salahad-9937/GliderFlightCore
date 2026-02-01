#ifndef CALIBRATION_H
#define CALIBRATION_H

#include <ArduinoJson.h>
#include "BarometerDriver.h"
#include "KalmanFilter.h"
#include "../core/Storage.h"
#include "../config/Config.h"

namespace Sensors
{

    class CalibrationState
    {
    public:
        virtual void update(unsigned long now) = 0;
        virtual int getProgress() = 0;
        virtual String getPhaseName() = 0;
        virtual void onEnter() {}
        virtual bool isMeasuring() { return true; }
        virtual bool isIdle() { return false; }
    };

    double basePressure = 0;
    double adaptiveBaseline = 0;
    double storedBasePressure = 0;
    extern KalmanState kAlt;
    extern int stableReadings;

    class IdleState : public CalibrationState
    {
    public:
        void update(unsigned long now) override {}
        int getProgress() override { return 0; }
        String getPhaseName() override { return "idle"; }
        bool isMeasuring() override { return false; }
        bool isIdle() override { return true; }
    };

    class WarmupState : public CalibrationState
    {
        unsigned long startTime;
        unsigned long lastSample;

    public:
        void onEnter() override
        {
            startTime = lastSample = millis();
        }
        void update(unsigned long now) override
        {
            if (now - lastSample >= 50)
            {
                lastSample = now;
                readPressure();
                readTemperature();
            }
            if (now - startTime >= 10000)
            {
                Serial.println("[Sensors] Термостабилизация завершена -> Сбор данных");
                void transitionToMeasuring();
                transitionToMeasuring();
            }
        }
        int getProgress() override
        {
            return constrain(((millis() - startTime) * 100) / 10000, 0, 99);
        }
        String getPhaseName() override { return "stabilization"; }
    };

    class MeasuringState : public CalibrationState
    {
        int samples = 0;
        double sum = 0;
        unsigned long lastSample;

    public:
        void onEnter() override
        {
            samples = 0;
            sum = 0;
            lastSample = millis();
        }
        void update(unsigned long now) override
        {
            if (now - lastSample >= 5)
            {
                lastSample = now;
                sum += readPressure();
                samples++;

                if (samples >= 2000)
                {
                    basePressure = sum / 2000.0;
                    adaptiveBaseline = basePressure;
                    kAlt.x = 0;
                    sys.calibrated = true;
                    Serial.print("[Sensors] Калибровка завершена. База: ");
                    Serial.println(basePressure, 2);
                    void transitionToIdle();
                    transitionToIdle();
                }
            }
        }
        int getProgress() override { return constrain((samples * 100) / 2000, 0, 99); }
        String getPhaseName() override { return "measuring"; }
    };

    class ZeroingState : public CalibrationState
    {
        int samples = 0;
        double sum = 0;

    public:
        void onEnter() override
        {
            samples = 0;
            sum = 0;
        }
        void update(unsigned long now) override
        {
            sum += readPressure();
            samples++;

            if (samples >= 500)
            {
                adaptiveBaseline = sum / 500.0;
                kAlt.x = 0;
                stableReadings = 0;
                sys.calibrated = true;
                Serial.print("[Sensors] Ноль установлен: ");
                Serial.println(adaptiveBaseline, 2);
                void transitionToIdle();
                transitionToIdle();
            }
        }
        int getProgress() override { return constrain((samples * 100) / 500, 0, 99); }
        String getPhaseName() override { return "zeroing"; }
    };

    IdleState idleStateObj;
    WarmupState warmupStateObj;
    MeasuringState measuringStateObj;
    ZeroingState zeroingStateObj;
    CalibrationState *currentState = &idleStateObj;

    void transitionToIdle()
    {
        currentState = &idleStateObj;
        currentState->onEnter();
    }
    void transitionToMeasuring()
    {
        currentState = &measuringStateObj;
        currentState->onEnter();
    }

    bool isCalibrationIdle() { return currentState->isIdle(); }

    void startCalibration()
    {
        if (!sys.hardwareOK)
            return;
        Serial.println("[Sensors] Запуск неблокирующей калибровки...");
        sys.calibrated = false;
        currentState = &warmupStateObj;
        currentState->onEnter();
    }

    void startZeroing()
    {
        if (!sys.hardwareOK)
            return;
        Serial.println("[Sensors] Запуск неблокирующего обнуления...");
        currentState = &zeroingStateObj;
        currentState->onEnter();
    }

    void cancel()
    {
        if (currentState->isIdle())
            return;
        Serial.println("[Sensors] Операция прервана пользователем!");
        transitionToIdle();
    }

    void updateCalibrationLogic()
    {
        currentState->update(millis());
    }

    int getCalibrationProgress() { return currentState->getProgress(); }
    String getCalibrationPhase() { return currentState->getPhaseName(); }

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
                storedBasePressure = basePressure = adaptiveBaseline = val;
                kAlt.x = 0;
                sys.calibrated = true;
                Serial.print("[Sensors] Данные успешно загружены из ФС: ");
                Serial.println(storedBasePressure);
            }
        }
    }
}
#endif