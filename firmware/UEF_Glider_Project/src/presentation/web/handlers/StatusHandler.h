#ifndef PRESENTATION_WEB_HANDLERS_STATUS_H
#define PRESENTATION_WEB_HANDLERS_STATUS_H

#include "../ApiService.h"
#include <ArduinoJson.h>

namespace presentation::web::handlers
{
    /**
     * Маппинг внутреннего статуса калибровки в строковую фазу для API.
     */
    inline auto mapStatusToPhase(application::events::CalibrationStatus status) -> const char *
    {
        using application::events::CalibrationStatus;

        switch (status)
        {
        case CalibrationStatus::WARMUP:
            return "stabilization";
        case CalibrationStatus::MEASURING:
            return "measuring";
        case CalibrationStatus::ZEROING:
            return "zeroing";
        default:
            return "idle";
        }
    }

    inline void handleStatus(ApiService &api)
    {
        // Исправлено: замена StaticJsonDocument на JsonDocument (ArduinoJson v7)
        JsonDocument doc;

        const auto &tData = api.telemetry().getData();
        const auto &cRes = api.calib().getLastResult();
        auto vccRes = api.vcc().readVoltage();

        doc["status"] = "ok";
        doc["hw_ok"] = true;
        doc["calibrated"] = cRes.isValid;
        doc["calibrating"] = (api.calib().getStatus() != application::events::CalibrationStatus::IDLE);
        doc["monitoring"] = api.telemetry().isMonitoring();
        doc["logging"] = api.telemetry().isLogging();

        doc["stored_base"] = cRes.basePressure;
        doc["current_p"] = tData.pressure;
        doc["base"] = cRes.basePressure;

        if (api.telemetry().isMonitoring())
        {
            doc["alt"] = tData.altitude;
            doc["temp"] = tData.temperature;
            doc["stable"] = tData.isStable;
        }

        doc["calib_phase"] = mapStatusToPhase(api.calib().getStatus());
        doc["calib_progress"] = api.calib().getProgress();

        doc["vcc"] = vccRes.isOk() ? vccRes.value() : 0.0f;
        doc["flight_mode"] = static_cast<int>(api.flight().getCurrentMode());

        String output;
        serializeJson(doc, output);
        api.server().send(200, "application/json", output);
    }
}

#endif