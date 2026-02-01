#ifndef STATUS_HANDLER_H
#define STATUS_HANDLER_H

#include <ArduinoJson.h>
#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network
{

    void fillHardwareStatus(JsonObject &doc)
    {
        doc["hw_ok"] = Sensors::sys.hardwareOK;
        doc["vcc"] = ESP.getVcc() / 1000.0;
    }

    void fillCalibrationStatus(JsonObject &doc)
    {
        doc["calibrated"] = Sensors::sys.calibrated;
        doc["calibrating"] = (Sensors::calibState != Sensors::CALIB_IDLE);
        doc["calib_phase"] = Sensors::getCalibrationPhase();
        doc["calib_progress"] = Sensors::getCalibrationProgress();
        doc["stored_base"] = Sensors::storedBasePressure;
    }

    void fillTelemetryStatus(JsonObject &doc)
    {
        doc["monitoring"] = Sensors::sys.monitoring;
        doc["logging"] = Sensors::sys.logging;

        if (Sensors::sys.monitoring)
        {
            doc["current_p"] = Sensors::telemetry.pressure;
        }

        if (Sensors::sys.calibrated && Sensors::sys.monitoring)
        {
            doc["alt"] = Sensors::telemetry.altitude;
            doc["temp"] = Sensors::telemetry.temperature;
            doc["stable"] = Sensors::telemetry.isStable;
            doc["base"] = Sensors::basePressure;
        }
    }

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