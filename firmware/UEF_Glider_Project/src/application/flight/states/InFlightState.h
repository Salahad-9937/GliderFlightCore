#ifndef APPLICATION_FLIGHT_STATES_IN_FLIGHT_H
#define APPLICATION_FLIGHT_STATES_IN_FLIGHT_H

#include "BaseFlightState.h"
#include "../../../core2/hal/INetwork.h"
#include "../../../core2/hal/IStorage.h"
#include "../../../core2/engine/Sequencer.h"
#include "../../../application/flight/ProgramManager.h"
#include "../../../application/telemetry/TelemetryService.h"
#include "../../../infrastructure/persistence/StorageKeys.h"
#include <ESP8266WiFi.h>

namespace application::flight
{
    /**
     * @brief Состояние активного полета.
     */
    class InFlightState : public BaseFlightState
    {
    public:
        InFlightState(core2::hal::INetwork &net,
                      core2::hal::IActuator &servo,
                      ProgramManager &progManager,
                      core2::hal::IStorage &storage,
                      application::telemetry::TelemetryService &telemetry)
            : _net(&net),
              _sequencer(servo),
              _progManager(&progManager),
              _storage(&storage),
              _telemetry(&telemetry) {}

        [[nodiscard]] auto getName() const -> const char * override { return "FLIGHT"; }
        [[nodiscard]] auto isConfigLocked() const -> bool override { return true; }

        auto onEnter() -> void override
        {
            core2::Registry::getLogger().info("FLIGHT: Старт автономной программы...\n");
            _net->setPower(false);

            if (_progManager->hasActiveProgram())
            {
                const auto &prog = _progManager->getActiveProgram();
                _sequencer.start(prog.steps, prog.stepsCount, millis());
            }
            _lastLogTime = 0;
        }

        auto handleGesture(application::events::HallGesture gesture) -> BaseFlightState * override
        {
            (void)gesture;
            return nullptr; // В полете жесты игнорируются (защита)
        }

        auto onUpdate(uint32_t now) -> void override
        {
            _sequencer.update(now);

            if (now - _lastLogTime >= 1000)
            {
                _lastLogTime = now;
                float p = _telemetry->getData().pressure;
                _storage->append(static_cast<uint16_t>(infrastructure::persistence::StorageKey::FLIGHT_LOG), &p, sizeof(p));
            }
        }

        auto onExit() -> void override
        {
            _sequencer.stop();
            _net->setPower(true);
            WiFi.mode(WIFI_AP);
            core2::Registry::getLogger().info("FLIGHT: Программа завершена.\n");
        }

    private:
        core2::hal::INetwork *_net;
        core2::Sequencer _sequencer;
        ProgramManager *_progManager;
        core2::hal::IStorage *_storage;
        application::telemetry::TelemetryService *_telemetry;

        uint32_t _lastLogTime = 0;
    };
}

#endif