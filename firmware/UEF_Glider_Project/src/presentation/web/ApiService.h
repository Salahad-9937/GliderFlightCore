#ifndef PRESENTATION_WEB_API_SERVICE_H
#define PRESENTATION_WEB_API_SERVICE_H

#include <ESP8266WebServer.h>
#include "../../core2/engine/Scheduler.h"
#include "../../application/telemetry/TelemetryService.h"
#include "../../application/calibration/CalibrationService.h"
#include "../../application/flight/FlightService.h"
#include "../../application/flight/ProgramManager.h"
#include "../../drivers/power/VccMonitor.h"
#include "../../drivers/system/SystemMonitor.h"

namespace presentation::web
{
    /**
     * @brief Сервис управления HTTP API.
     * Наследует ITask для интеграции в планировщик.
     */
    class ApiService : public core2::ITask
    {
    public:
        explicit ApiService(
            application::telemetry::TelemetryService &telemetry,
            application::calibration::CalibrationService &calib,
            application::flight::FlightService &flight,
            application::flight::ProgramManager &program,
            drivers::VccMonitor &vcc,
            drivers::SystemMonitor &sys)
            : _server(80),
              _telemetry(&telemetry),
              _calib(&calib),
              _flight(&flight),
              _program(&program),
              _vcc(&vcc),
              _sys(&sys) {}

        /**
         * @brief Регистрация маршрутов и запуск сервера.
         */
        auto begin() -> void;

        /**
         * @brief Цикл обработки запросов.
         */
        void execute(uint32_t now) override
        {
            (void)now;
            _server.handleClient();
        }

        // Геттеры для хендлеров
        auto server() -> ESP8266WebServer & { return _server; }
        auto telemetry() -> application::telemetry::TelemetryService & { return *_telemetry; }
        auto calib() -> application::calibration::CalibrationService & { return *_calib; }
        auto flight() -> application::flight::FlightService & { return *_flight; }
        auto program() -> application::flight::ProgramManager & { return *_program; }
        auto vcc() -> drivers::VccMonitor & { return *_vcc; }
        auto sys() -> drivers::SystemMonitor & { return *_sys; }

    private:
        ESP8266WebServer _server;
        application::telemetry::TelemetryService *_telemetry;
        application::calibration::CalibrationService *_calib;
        application::flight::FlightService *_flight;
        application::flight::ProgramManager *_program;
        drivers::VccMonitor *_vcc;
        drivers::SystemMonitor *_sys;
    };
}

#endif