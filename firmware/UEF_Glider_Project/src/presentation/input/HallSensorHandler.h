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
     * @brief Обработчик физического уровня датчика Холла.
     * Реализует распознавание жестов: клик, двойной клик, удержание.
     */
    class HallSensorHandler : public ITask
    {
    public:
        static constexpr uint32_t DEBOUNCE_MS = 50;
        static constexpr uint32_t DOUBLE_CLICK_MS = 500;
        static constexpr uint32_t LONG_PRESS_MS = 3000;

        explicit HallSensorHandler(hal::IDigitalInput &input, EventBus<> &eventBus)
            : _input(&input), _eventBus(&eventBus) {}

        void execute(uint32_t now) override
        {
            processPhysicalLevel(now);
            processLongPress(now);
            processClickTimeout(now);
        }

    private:
        /**
         * Обработка изменения физического уровня с антидребезгом.
         */
        void processPhysicalLevel(uint32_t now)
        {
            auto readRes = _input->read();
            if (!readRes.isOk())
                return;

            bool isActive = readRes.value();

            // Сброс таймера при любом изменении уровня
            if (isActive != _lastRawState)
            {
                _lastDebounceTime = now;
                _lastRawState = isActive;
                return;
            }

            // Если уровень стабилен, проверяем необходимость смены состояния
            if (now - _lastDebounceTime <= DEBOUNCE_MS)
                return;
            if (isActive == _stableState)
                return;

            _stableState = isActive;
            if (_stableState)
                handlePress(now);
            else
                handleRelease(now);
        }

        /**
         * Проверка длительного удержания.
         */
        void processLongPress(uint32_t now)
        {
            if (!_stableState)
                return;
            if (_longPressTriggered)
                return;
            if (now - _pressStartTime < LONG_PRESS_MS)
                return;

            _longPressTriggered = true;
            _eventBus->publish(HallEvent::ID, HallEvent(HallGesture::LONG_PRESS_START));
        }

        /**
         * Проверка таймаута для завершения серии кликов.
         */
        void processClickTimeout(uint32_t now)
        {
            if (_stableState)
                return;
            if (_clickCount == 0)
                return;
            if (now - _lastReleaseTime < DOUBLE_CLICK_MS)
                return;

            HallGesture gesture = (_clickCount >= 2) ? HallGesture::DOUBLE_CLICK : HallGesture::CLICK;
            _eventBus->publish(HallEvent::ID, HallEvent(gesture));

            _clickCount = 0;
        }

        void handlePress(uint32_t now)
        {
            _pressStartTime = now;
            _longPressTriggered = false;
        }

        void handleRelease(uint32_t now)
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