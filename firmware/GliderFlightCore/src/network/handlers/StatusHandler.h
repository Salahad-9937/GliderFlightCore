#ifndef STATUS_HANDLER_H
#define STATUS_HANDLER_H

#include <ArduinoJson.h>
#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network
{

    void fillHardwareStatus(JsonObject &doc)
    {
        doc["hw_ok"] = Sensors::isHardwareOK;
        doc["vcc"] = ESP.getVcc() / 1000.0;
    }

    void fillCalibrationStatus(JsonObject &doc)
    {
        doc["calibrated"] = Sensors::isCalibrated;
        doc["calibrating"] = (Sensors::calibState != Sensors::CALIB_IDLE);
        doc["calib_phase"] = Sensors::getCalibrationPhase();
        doc["calib_progress"] = Sensors::getCalibrationProgress();
        doc["stored_base"] = Sensors::storedBasePressure;
    }

    void fillTelemetryStatus(JsonObject &doc)
    {
        doc["monitoring"] = Sensors::isMonitoring;
        doc["logging"] = Sensors::isLogging;

        if (Sensors::isMonitoring)
        {
            doc["current_p"] = Sensors::telemetry.pressure;
        }

        if (Sensors::isCalibrated && Sensors::isMonitoring)
        {
            doc["alt"] = Sensors::telemetry.altitude;
            doc["temp"] = Sensors::telemetry.temperature;
            doc["stable"] = Sensors::telemetry.isStable;
            doc["base"] = Sensors::basePressure;
        }
    }

    /**
     * Возвращает полный статус устройства (Телеметрия)
     */
    void handleStatus()
    {
        Serial.println("[HTTP] Запрос статуса /status");

        StaticJsonDocument<512> doc;
        JsonObject obj = doc.to<JsonObject>();

        fillHardwareStatus(obj);
        fillCalibrationStatus(obj);
        fillTelemetryStatus(obj);

        String output;
        serializeJson(doc, output);
        server.send(200, "application/json", output);

        Serial.print("[HTTP] Ответ отправлен: ");
        Serial.println(output);
    }
}
#endif