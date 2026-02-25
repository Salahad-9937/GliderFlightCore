#ifndef PRESENTATION_WEB_HANDLERS_CONTROL_H
#define PRESENTATION_WEB_HANDLERS_CONTROL_H

#include "../ApiService.h"

namespace presentation::web::handlers
{
    inline void handleCalibrate(ApiService &api)
    {
        if (api.flight().isConfigLocked())
        {
            api.server().send(403, "text/plain", "Locked");
            return;
        }
        api.calib().startFull();
        api.server().send(202, "text/plain", "Accepted");
    }

    inline void handleZero(ApiService &api)
    {
        if (api.flight().isConfigLocked())
        {
            api.server().send(403, "text/plain", "Locked");
            return;
        }
        api.calib().startZero();
        api.server().send(202, "text/plain", "Accepted");
    }

    inline void handleCancel(ApiService &api)
    {
        api.calib().cancel();
        api.server().send(200, "text/plain", "OK");
    }

    inline void handleSaveCalib(ApiService &api)
    {
        if (api.flight().isConfigLocked())
        {
            api.server().send(403, "text/plain", "Locked");
            return;
        }
        if (api.calib().saveToStorage().isOk())
            api.server().send(200, "text/plain", "OK");
        else
            api.server().send(500, "text/plain", "Error");
    }

    // НОВЫЕ ОБРАБОТЧИКИ ДЛЯ СОВМЕСТИМОСТИ

    inline void handleBaroControl(ApiService &api)
    {
        if (api.server().hasArg("enable"))
        {
            bool en = (api.server().arg("enable") == "1");
            api.telemetry().setMonitoring(en);
            api.server().send(200, "text/plain", "OK");
        }
        else
            api.server().send(400);
    }

    inline void handleLogControl(ApiService &api)
    {
        if (api.server().hasArg("enable"))
        {
            bool en = (api.server().arg("enable") == "1");
            api.telemetry().setLogging(en);
            api.server().send(200, "text/plain", "OK");
        }
        else
            api.server().send(400);
    }
}

#endif