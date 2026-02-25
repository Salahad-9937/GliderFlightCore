#ifndef PRESENTATION_INDICATION_PATTERN_H
#define PRESENTATION_INDICATION_PATTERN_H

#include "../../drivers/led/LedChannel.h"
#include <stdint.h>

namespace presentation::indication
{
    /**
     * @brief Интерфейс стратегии мигания светодиодом.
     * Позволяет добавлять новые паттерны без изменения сервиса (OCP).
     */
    class IIndicationPattern
    {
    public:
        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        virtual ~IIndicationPattern() = default;
        IIndicationPattern() = default;
        IIndicationPattern(const IIndicationPattern &) = delete;
        auto operator=(const IIndicationPattern &) -> IIndicationPattern & = delete;
        IIndicationPattern(IIndicationPattern &&) = delete;
        auto operator=(IIndicationPattern &&) -> IIndicationPattern & = delete;

        virtual void update(uint32_t now, drivers::LedChannel &led) = 0;
        virtual void reset() = 0;
    };

    /**
     * @brief Реализация: Медленное мигание.
     */
    class BlinkPattern : public IIndicationPattern
    {
    public:
        explicit BlinkPattern(uint32_t interval) : _interval(interval) {}
        void update(uint32_t now, drivers::LedChannel &led) override
        {
            if (now - _lastTime >= _interval)
            {
                led.toggle();
                _lastTime = now;
            }
        }
        void reset() override { _lastTime = 0; }

    private:
        uint32_t _interval;
        uint32_t _lastTime = 0;
    };

    /**
     * @brief Реализация: Постоянное свечение.
     */
    class SteadyPattern : public IIndicationPattern
    {
    public:
        explicit SteadyPattern(bool state) : _state(state) {}
        void update(uint32_t now, drivers::LedChannel &led) override
        {
            (void)now;
            led.set(_state);
        }
        void reset() override {}

    private:
        bool _state;
    };
}

#endif