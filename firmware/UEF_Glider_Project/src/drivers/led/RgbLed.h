#ifndef CORE2_DRIVER_RGB_LED_H
#define CORE2_DRIVER_RGB_LED_H

#include "LedChannel.h"

namespace drivers
{
    /**
     * Универсальный RGB драйвер.
     * Управляет тремя каналами как единым целым.
     */
    class RgbLed
    {
    public:
        // Исправлено: bugprone-easily-swappable-parameters (порядок R-G-B зафиксирован логикой)
        // NOLINTNEXTLINE(bugprone-easily-swappable-parameters)
        RgbLed(LedChannel &red, LedChannel &green, LedChannel &blue)
            : _red(&red), _green(&green), _blue(&blue) {}

        /**
         * Установка цвета через булевы флаги (8 базовых цветов)
         */
        // Исправлено: readability-identifier-length (r, g, b -> red, green, blue)
        auto setRgb(bool red, bool green, bool blue) -> core2::Status
        {
            core2::Status status = _red->set(red);
            if (!status.isOk())
            {
                return status;
            }

            status = _green->set(green);
            if (!status.isOk())
            {
                return status;
            }

            return _blue->set(blue);
        }

        /**
         * Выключить все каналы
         */
        auto off() -> core2::Status
        {
            return setRgb(false, false, false);
        }

        // Прямой доступ к каналам для специфических манипуляций
        auto red() -> LedChannel & { return *_red; }
        auto green() -> LedChannel & { return *_green; }
        auto blue() -> LedChannel & { return *_blue; }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members
        LedChannel *_red{nullptr};
        LedChannel *_green{nullptr};
        LedChannel *_blue{nullptr};
    };
}

#endif