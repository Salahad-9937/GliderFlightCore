#ifndef PRESENTATION_INDICATION_PATTERN_H
#define PRESENTATION_INDICATION_PATTERN_H

#include "../../drivers/led/DualLed.h"
#include <stdint.h>

namespace presentation::indication
{
    /**
     * @brief Интерфейс стратегии индикации для двухцветного светодиода.
     */
    class IIndicationPattern
    {
    public:
        virtual ~IIndicationPattern() = default;
        IIndicationPattern() = default;
        IIndicationPattern(const IIndicationPattern &) = delete;
        auto operator=(const IIndicationPattern &) -> IIndicationPattern & = delete;
        IIndicationPattern(IIndicationPattern &&) = delete;
        auto operator=(IIndicationPattern &&) -> IIndicationPattern & = delete;

        /**
         * @param now Текущее время в мс
         * @param led Ссылка на драйвер двухцветного светодиода
         */
        virtual void update(uint32_t now, drivers::DualLed &led) = 0;
        virtual void reset() = 0;
    };

    /**
     * @brief Паттерн: Постоянное свечение выбранным цветом.
     */
    class SteadyPattern : public IIndicationPattern
    {
    public:
        explicit SteadyPattern(bool c1, bool c2) : _c1(c1), _c2(c2) {}
        void update(uint32_t now, drivers::DualLed &led) override
        {
            (void)now;
            (void)led.set(_c1, _c2);
        }
        void reset() override {}

    private:
        bool _c1;
        bool _c2;
    };

    /**
     * @brief Паттерн: Обычное мигание выбранным цветом.
     */
    class BlinkPattern : public IIndicationPattern
    {
    public:
        explicit BlinkPattern(uint32_t interval, bool c1, bool c2)
            : _interval(interval), _c1(c1), _c2(c2) {}

        void update(uint32_t now, drivers::DualLed &led) override
        {
            if (now - _lastTime >= _interval)
            {
                _state = !_state;
                _lastTime = now;
            }
            (void)led.set(_state ? _c1 : false, _state ? _c2 : false);
        }
        void reset() override
        {
            _lastTime = 0;
            _state = false;
        }

    private:
        uint32_t _interval;
        bool _c1;
        bool _c2;
        uint32_t _lastTime = 0;
        bool _state = false;
    };

    /**
     * @brief Паттерн: Сердцебиение (два коротких импульса).
     */
    class HeartbeatPattern : public IIndicationPattern
    {
    public:
        explicit HeartbeatPattern(bool c1, bool c2) : _c1(c1), _c2(c2) {}

        void update(uint32_t now, drivers::DualLed &led) override
        {
            uint32_t phase = now % 2000; // Цикл 1 секунда
            bool on = false;

            // Два удара: 0-70мс и 220-290мс
            if ((phase > 0 && phase < 70) || (phase > 220 && phase < 290))
            {
                on = true;
            }

            (void)led.set(on ? _c1 : false, on ? _c2 : false);
        }
        void reset() override {}

    private:
        bool _c1;
        bool _c2;
    };
}

#endif