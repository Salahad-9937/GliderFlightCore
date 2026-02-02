#ifndef CALIBRATION_H
#define CALIBRATION_H

#include "fsm/CalibrationState.h"
#include "fsm/IdleState.h"
#include "fsm/WarmupState.h"
#include "fsm/MeasuringState.h"
#include "fsm/ZeroingState.h"
#include "../core/Storage.h"

namespace Sensors
{
    // Инициализация статических объектов состояний
    IdleState idleStateObj;
    WarmupState warmupStateObj;
    MeasuringState measuringStateObj;
    ZeroingState zeroingStateObj;

    CalibrationState *currentState = &idleStateObj;

    /**
     * Реализация функций переходов
     */
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

    // API управления калибровкой
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

    void updateCalibrationLogic() { currentState->update(millis()); }
    int getCalibrationProgress() { return currentState->getProgress(); }
    String getCalibrationPhase() { return currentState->getPhaseName(); }

    bool saveToFS()
    {
        if (!sys.calibrated)
            return false;
        if (Storage::saveCalibration(calData.serialize()))
        {
            calData.storedBasePressure = calData.basePressure;
            Serial.print("[Sensors] Калибровка сохранена в ФС: ");
            Serial.println(calData.storedBasePressure, 2);
            return true;
        }
        return false;
    }

    void loadFromFS()
    {
        if (calData.deserialize(Storage::loadCalibration()))
        {
            kAlt.x = 0;
            sys.calibrated = true;
            Serial.print("[Sensors] Данные успешно загружены из ФС: ");
            Serial.println(calData.storedBasePressure);
        }
    }
}
#endif