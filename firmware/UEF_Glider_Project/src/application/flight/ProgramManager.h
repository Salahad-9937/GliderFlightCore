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
     * Отвечает за сохранение, загрузку и верификацию активной программы.
     */
    class ProgramManager
    {
    public:
        /**
         * @param persistence Ссылка на менеджер постоянного хранения.
         */
        explicit ProgramManager(PersistenceManager &persistence)
            : _persistence(&persistence) {}

        /**
         * @brief Сохранение программы в энергонезависимую память.
         * @param program Объект программы для записи.
         * @return Status Результат операции (OK или ошибка записи/CRC).
         */
        auto saveProgram(const FlightProgram &program) -> Status
        {
            if (!program.isValid())
            {
                Registry::getLogger().error("PROG: Попытка сохранить невалидную программу!\n");
                return ErrorCode::INVALID_ARGUMENT;
            }

            auto status = _persistence->save(StorageKey::FLIGHT_PROGRAM, program);
            if (status.isOk())
            {
                _activeProgram = program;
                _isLoaded = true;
                Registry::getLogger().info("PROG: Программа успешно сохранена.\n");
            }
            return status;
        }

        /**
         * @brief Загрузка программы из памяти.
         * @return Status Результат (NOT_FOUND если файл отсутствует).
         */
        auto loadActiveProgram() -> Status
        {
            FlightProgram buffer;
            auto status = _persistence->load(StorageKey::FLIGHT_PROGRAM, buffer);

            if (status.isOk())
            {
                _activeProgram = buffer;
                _isLoaded = true;
                Registry::getLogger().info("PROG: Активная программа загружена.\n");
            }
            return status;
        }

        /**
         * @brief Получение текущей загруженной программы.
         */
        [[nodiscard]] auto getActiveProgram() const -> const FlightProgram &
        {
            return _activeProgram;
        }

        /**
         * @brief Проверка наличия загруженной программы.
         */
        [[nodiscard]] auto hasActiveProgram() const -> bool { return _isLoaded; }

    private:
        PersistenceManager *_persistence;
        FlightProgram _activeProgram;
        bool _isLoaded = false;
    };
}

#endif