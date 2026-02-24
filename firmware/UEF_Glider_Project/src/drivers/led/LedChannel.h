#ifndef CORE2_DRIVER_LED_CHANNEL_H
#define CORE2_DRIVER_LED_CHANNEL_H

#include "../../core2/hal/IGpio.h"
#include "../../core2/base/Result.h"

namespace drivers
{
    /**
     * Драйвер одиночного LED канала.
     * Поддерживает инверсию логики (для схем с общим анодом).
     */
    class LedChannel
    {
    public:
        /**
         * @param output Ссылка на HAL интерфейс пина
         * @param inverted true для Common Anode (LOW = ON), false для Common Cathode (HIGH = ON)
         */
        explicit LedChannel(core2::hal::IDigitalOutput &output, bool inverted = false)
            : _output(&output), _inverted(inverted) {}

        /**
         * Включить светодиод
         */
        auto on() -> core2::Status { return set(true); }

        /**
         * Выключить светодиод
         */
        auto off() -> core2::Status { return set(false); }

        /**
         * Установить произвольное состояние
         */
        auto set(bool active) -> core2::Status
        {
            _state = active;
            // Если инвертировано: true -> LOW (false), false -> HIGH (true)
            // Если обычно: true -> HIGH (true), false -> LOW (false)
            return _output->write(_inverted ? !active : active);
        }

        /**
         * Переключить состояние (Toggle)
         */
        auto toggle() -> core2::Status
        {
            return set(!_state);
        }

        [[nodiscard]] auto isOn() const -> bool { return _state; }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members (удалены ссылки и const поля)
        core2::hal::IDigitalOutput *_output{nullptr};
        bool _inverted{false};

        // Исправлено: cppcoreguidelines-use-default-member-init
        bool _state{false};
    };
}

#endif