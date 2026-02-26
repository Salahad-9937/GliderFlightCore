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
     * В новой логике: durationMs — это время ожидания ПЕРЕД установкой value.
     */
    struct SequenceStep
    {
        int16_t value;
        uint32_t durationMs;
    };

    /**
     * Исполнитель последовательностей (Sequencer).
     * Реализует логику: Ждать -> Повернуть -> Перейти к следующему шагу.
     */
    class Sequencer
    {
    public:
        explicit Sequencer(hal::IActuator &actuator)
            : _actuator(&actuator) {}

        /**
         * Запуск программы.
         * В отличие от старой версии, НЕ устанавливает значение немедленно.
         */
        auto start(const SequenceStep *program, size_t size, uint32_t now) -> Status
        {
            if (program == nullptr || size == 0)
            {
                return Status::fail(ErrorCode::INVALID_ARGUMENT);
            }

            _program = program;
            _programSize = size;
            _currentIndex = 0;
            _startTime = now;
            _isRunning = true;

            return Status::ok();
        }

        /**
         * Обновление состояния.
         * Сначала отсчитывает время, затем выполняет действие.
         */
        auto update(uint32_t now) -> Status
        {
            if (!_isRunning)
            {
                return Status::ok();
            }

            uint32_t elapsed = now - _startTime;

            // Если время ожидания текущего шага истекло
            if (elapsed >= _program[_currentIndex].durationMs)
            {
                // Выполняем действие (поворот на угол)
                Status status = _actuator->setValue(_program[_currentIndex].value);
                if (!status.isOk())
                {
                    _isRunning = false;
                    return status;
                }

                // Переходим к следующему шагу
                _currentIndex++;
                _startTime = now;

                // Если шаги закончились — останавливаемся
                if (_currentIndex >= _programSize)
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
        hal::IActuator *_actuator{nullptr};
        const SequenceStep *_program{nullptr};
        size_t _programSize{0};
        size_t _currentIndex{0};
        uint32_t _startTime{0};
        bool _isRunning{false};
    };

} // namespace core2

#endif