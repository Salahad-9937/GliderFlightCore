#ifndef APPLICATION_FLIGHT_PROGRAM_MANAGER_H
#define APPLICATION_FLIGHT_PROGRAM_MANAGER_H

#include "../../domain/flight/FlightProgram.h"
#include "../../infrastructure/persistence/PersistenceManager.h"
#include "../../core2/base/Registry.h"

namespace application::flight
{
    using namespace core2;
    using namespace domain::flight;
    using namespace infrastructure::persistence;

    /**
     * @brief Сервис управления жизненным циклом полетных программ.
     */
    class ProgramManager
    {
    public:
        explicit ProgramManager(PersistenceManager &persistence)
            : _persistence(&persistence) {}

        /**
         * @brief Сохранение программы с расширенной валидацией.
         */
        auto saveProgram(const FlightProgram &program) -> Status
        {
            if (!program.isValid())
            {
                Registry::getLogger().error("PROG: Невалидная структура программы\n");
                return ErrorCode::INVALID_ARGUMENT;
            }

            // Проверка: не пытаемся ли мы сохранить ту же самую программу
            if (_isLoaded && _activeProgram.isSameAs(program))
            {
                Registry::getLogger().debug("PROG: Программа идентична текущей, пропуск записи\n");
                return Status::ok();
            }

            auto status = _persistence->save(StorageKey::FLIGHT_PROGRAM, program);
            if (status.isOk())
            {
                _activeProgram = program;
                _isLoaded = true;
                Registry::getLogger().info("PROG: Новая программа сохранена и активирована\n");
            }
            return status;
        }

        auto loadActiveProgram() -> Status
        {
            FlightProgram buffer;
            auto status = _persistence->load(StorageKey::FLIGHT_PROGRAM, buffer);

            if (status.isOk())
            {
                _activeProgram = buffer;
                _isLoaded = true;
            }
            return status;
        }

        [[nodiscard]] auto getActiveProgram() const -> const FlightProgram &
        {
            return _activeProgram;
        }

        [[nodiscard]] auto hasActiveProgram() const -> bool { return _isLoaded; }

    private:
        PersistenceManager *_persistence;
        FlightProgram _activeProgram;
        bool _isLoaded = false;
    };
}

#endif