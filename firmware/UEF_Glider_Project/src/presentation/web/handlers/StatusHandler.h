#ifndef PRESENTATION_WEB_HANDLERS_STATUS_H
#define PRESENTATION_WEB_HANDLERS_STATUS_H

#include "../ApiService.h"
#include <ArduinoJson.h>

namespace presentation::web::handlers
{
    inline void handleStatus(ApiService &api)
    {
        StaticJsonDocument<1024> doc;

        const auto &tData = api.telemetry().getData();
        const auto &cRes = api.calib().getLastResult();
        auto vccRes = api.vcc().readVoltage();

        // Обязательное поле для клиента
        doc["status"] = "ok";

        // 1. Статусы (1:1 со старой прошивкой)
        doc["hw_ok"] = true;
        doc["calibrated"] = cRes.isValid;
        doc["calibrating"] = (api.calib().getStatus() != application::events::CalibrationStatus::IDLE);
        doc["monitoring"] = api.telemetry().isMonitoring();
        doc["logging"] = api.telemetry().isLogging();

        // 2. Давление и база
        doc["stored_base"] = cRes.basePressure;
        doc["current_p"] = tData.pressure;
        doc["base"] = cRes.basePressure;

        // 3. Телеметрия (только если включен мониторинг)
        if (api.telemetry().isMonitoring())
        {
            doc["alt"] = tData.altitude;
            doc["temp"] = tData.temperature;
            doc["stable"] = tData.isStable;
        }

        // 4. Фаза и ПРОГРЕСС (Критично для UI)
        const char *phase = "idle";
        switch (api.calib().getStatus())
        {
        case application::events::CalibrationStatus::WARMUP:
            phase = "stabilization";
            break;
        case application::events::CalibrationStatus::MEASURING:
            phase = "measuring";
            break;
        case application::events::CalibrationStatus::ZEROING:
            phase = "zeroing";
            break;
        default:
            phase = "idle";
            break;
        }
        doc["calib_phase"] = phase;
        doc["calib_progress"] = api.calib().getProgress();

        // 5. Системные данные
        doc["vcc"] = vccRes.isOk() ? vccRes.value() : 0.0f;
        doc["flight_mode"] = static_cast<int>(api.flight().getCurrentMode());

        String output;
        serializeJson(doc, output);
        api.server().send(200, "application/json", output);
    }
}

#endif