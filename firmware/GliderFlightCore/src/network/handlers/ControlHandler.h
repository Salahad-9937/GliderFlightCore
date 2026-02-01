#ifndef CONTROL_HANDLER_H
#define CONTROL_HANDLER_H

#include "../../core/Sensors.h"
#include "../WebServer.h"

namespace Network
{
    void handleZero()
    {
        Serial.println("[HTTP] Команда на обнуление /zero");
        if (!Sensors::sys.hardwareOK)
        {
            server.send(503, "text/plain", "Hardware Error");
            return;
        }

        if (Sensors::calibState != Sensors::CALIB_IDLE)
        {
            server.send(409, "text/plain", "Calibration/Zeroing already in progress");
            return;
        }

        Sensors::startZeroing();
        server.send(202, "text/plain", "Zeroing started");
    }

    void handleBaroControl()
    {
        if (server.hasArg("enable"))
        {
            bool enable = (server.arg("enable") == "1");
            Sensors::sys.monitoring = enable;
            Serial.print("[HTTP] Мониторинг барометра: ");
            Serial.println(enable ? "ВКЛ" : "ВЫКЛ");
            server.send(200, "text/plain", enable ? "Monitoring Enabled" : "Monitoring Disabled");
        }
        else
        {
            server.send(400, "text/plain", "Bad Request: missing 'enable' arg");
        }
    }

    void handleLogControl()
    {
        if (server.hasArg("enable"))
        {
            bool enable = (server.arg("enable") == "1");
            Sensors::sys.logging = enable;
            if (enable)
                Sensors::logStartTime = millis();
            Serial.print("[HTTP] Логирование в Serial: ");
            Serial.println(enable ? "ВКЛ" : "ВЫКЛ");
            server.send(200, "text/plain", "OK");
        }
        else
        {
            server.send(400, "text/plain", "Missing 'enable' arg");
        }
    }
}
#endif