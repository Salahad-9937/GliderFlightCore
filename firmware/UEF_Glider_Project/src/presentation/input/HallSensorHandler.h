#ifndef PRESENTATION_INPUT_HALL_HANDLER_H
#define PRESENTATION_INPUT_HALL_HANDLER_H

#include "../../core2/hal/IGpio.h"
#include "../../core2/base/Registry.h"
#include "../../core2/messaging/EventBus.h"
#include "../../core2/engine/Scheduler.h"
#include "../../application/events/InputEvents.h"

namespace presentation::input
{
    using namespace core2;
    using namespace application::events;

    /**
     * Обработчик физического уровня датчика Холла.
     * Реализует распознавание жестов: клик, двойной клик, удержание.
     * Наследует ITask для безопасной интеграции в планировщик.
     */
    class HallSensorHandler : public ITask
    {
    public:
        static constexpr uint32_t DEBOUNCE_MS = 50;
        static constexpr uint32_t DOUBLE_CLICK_MS = 500;
        static constexpr uint32_t LONG_PRESS_MS = 3000;

        explicit HallSensorHandler(hal::IDigitalInput &input, EventBus<> &eventBus)
            : _input(&input), _eventBus(&eventBus) {}

        /**
         * Реализация интерфейса ITask.
         */
        void execute(uint32_t now) override
        {
            update(now);
        }

        /**
         * Основной цикл обработки.
         */
        auto update(uint32_t now) -> void
        {
            auto readRes = _input->read();
            if (!readRes.isOk())
            {
                return;
            }

            // Инвертируем логику: LOW (false) означает срабатывание датчика Холла
            bool isActive = !readRes.value();

            // 1. Обработка изменения состояния (Антидребезг)
            if (isActive != _lastRawState)
            {
                _lastDebounceTime = now;
            }

            if ((now - _lastDebounceTime) > DEBOUNCE_MS)
            {
                if (isActive != _stableState)
                {
                    _stableState = isActive;
                    if (_stableState)
                    {
                        handlePress(now);
                    }
                    else
                    {
                        handleRelease(now);
                    }
                }
            }

            // 2. Проверка удержания (Long Press)
            if (_stableState && !_longPressTriggered)
            {
                if ((now - _pressStartTime) >= LONG_PRESS_MS)
                {
                    _longPressTriggered = true;
                    _eventBus->publish(HallEvent::ID, HallEvent(HallGesture::LONG_PRESS_START));
                }
            }

            // 3. Проверка таймаута двойного клика
            if (!_stableState && (_clickCount > 0))
            {
                if ((now - _lastReleaseTime) >= DOUBLE_CLICK_MS)
                {
                    if (_clickCount == 1)
                    {
                        _eventBus->publish(HallEvent::ID, HallEvent(HallGesture::CLICK));
                    }
                    else if (_clickCount >= 2)
                    {
                        _eventBus->publish(HallEvent::ID, HallEvent(HallGesture::DOUBLE_CLICK));
                    }

                    _clickCount = 0;
                }
            }

            _lastRawState = isActive;
        }

    private:
        auto handlePress(uint32_t now) -> void
        {
            _pressStartTime = now;
            _longPressTriggered = false;
        }

        auto handleRelease(uint32_t now) -> void
        {
            uint32_t duration = now - _pressStartTime;
            _lastReleaseTime = now;

            if (!_longPressTriggered)
            {
                _clickCount++;
            }

            _eventBus->publish(HallEvent::ID, HallEvent(HallGesture::RELEASE, duration));
        }

        hal::IDigitalInput *_input;
        EventBus<> *_eventBus;

        bool _lastRawState = false;
        bool _stableState = false;
        uint32_t _lastDebounceTime = 0;

        uint32_t _pressStartTime = 0;
        uint32_t _lastReleaseTime = 0;
        uint8_t _clickCount = 0;
        bool _longPressTriggered = false;
    };
}

#endif