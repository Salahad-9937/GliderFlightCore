#include "ApiService.h"
#include "handlers/StatusHandler.h"
#include "handlers/ProgramHandler.h"
#include "handlers/ControlHandler.h"
#include "handlers/SystemHandler.h"

namespace presentation::web
{
    using namespace handlers;

    auto ApiService::begin() -> void
    {
        _server.on("/status", HTTP_GET, [this]()
                   { handleStatus(*this); });
        _server.on("/program", HTTP_POST, [this]()
                   { handleProgramUpload(*this); });

        _server.on("/calibrate", HTTP_GET, [this]()
                   { handleCalibrate(*this); });
        _server.on("/zero", HTTP_GET, [this]()
                   { handleZero(*this); });
        _server.on("/cancel", HTTP_GET, [this]()
                   { handleCancel(*this); });
        _server.on("/calibrate/save", HTTP_GET, [this]()
                   { handleSaveCalib(*this); });

        // Восстановленные маршруты управления
        _server.on("/baro", HTTP_GET, [this]()
                   { handleBaroControl(*this); });
        _server.on("/log", HTTP_GET, [this]()
                   { handleLogControl(*this); });

        _server.on("/system", HTTP_GET, [this]()
                   { handleSystem(*this); });

        _server.onNotFound([this]()
                           { _server.send(404, "text/plain", "Not Found"); });

        _server.begin();
        core2::Registry::getLogger().info("WEB: API восстановлено (v1.2 compatible)\n");
    }
}