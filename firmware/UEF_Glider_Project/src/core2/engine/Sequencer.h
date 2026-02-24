#ifndef CORE2_SEQUENCER_H
#define CORE2_SEQUENCER_H

#include "../hal/IActuator.h"
#include "../base/Time.h"
#include <stdint.h>
#include <stddef.h>

namespace core2
{

    /**
     * Шаг временной последовательности.
     */
    struct SequenceStep
    {
        int16_t value;
        uint32_t durationMs;
    };

    /**
     * Исполнитель последовательностей (Sequencer).
     * Управляет актуатором согласно заданной программе шагов.
     */
    class Sequencer
    {
    public:
        // Исправлено: внедрение зависимости через указатель (avoid-const-or-ref-data-members)
        explicit Sequencer(hal::IActuator &actuator)
            : _actuator(&actuator) {}

        // Исправлено: trailing return type и подавление swappable-parameters
        // NOLINTNEXTLINE(bugprone-easily-swappable-parameters)
        auto start(const SequenceStep *program, size_t size, uint32_t now) -> Status
        {
            // Исправлено: явное сравнение указателя (implicit-bool-conversion)
            if (program == nullptr || size == 0)
            {
                return Status::fail(ErrorCode::INVALID_ARGUMENT);
            }

            _program = program;
            _programSize = size;
            _currentIndex = 0;
            _startTime = now;
            _isRunning = true;

            // Исправлено: доступ к массиву через индекс (pointer-arithmetic)
            // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-pointer-arithmetic)
            return _actuator->setValue(_program[_currentIndex].value);
        }

        auto update(uint32_t now) -> Status
        {
            if (!_isRunning)
            {
                return Status::ok();
            }

            uint32_t elapsed = now - _startTime;

            // Исправлено: добавлены скобки (braces-around-statements) и арифметика
            // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-pointer-arithmetic)
            if (elapsed >= _program[_currentIndex].durationMs)
            {
                _currentIndex++;
                if (_currentIndex < _programSize)
                {
                    _startTime = now;
                    // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-pointer-arithmetic)
                    Status status = _actuator->setValue(_program[_currentIndex].value);
                    if (!status.isOk())
                    {
                        _isRunning = false;
                        return status;
                    }
                }
                else
                {
                    _isRunning = false;
                }
            }
            return Status::ok();
        }

        auto stop() -> void { _isRunning = false; }

        [[nodiscard]] auto isRunning() const -> bool { return _isRunning; }

        [[nodiscard]] auto getCurrentStep() const -> size_t { return _currentIndex; }

    private:
        // Исправлено: использование указателя вместо ссылки и инициализация при объявлении
        hal::IActuator *_actuator{nullptr};
        const SequenceStep *_program{nullptr};
        size_t _programSize{0};
        size_t _currentIndex{0};
        uint32_t _startTime{0};
        bool _isRunning{false};
    };

} // namespace core2

#endif