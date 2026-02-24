#ifndef CORE2_DRIVER_DUAL_LED_H
#define CORE2_DRIVER_DUAL_LED_H

#include "LedChannel.h"

namespace drivers
{
    /**
     * Драйвер двухцветного светодиода (3 пина).
     */
    class DualLed
    {
    public:
        // Исправлено: переименование параметров (readability-identifier-length)
        DualLed(LedChannel &channel1, LedChannel &channel2)
            : _channel1(&channel1), _channel2(&channel2) {}

        /**
         * Установить состояние обоих каналов
         */
        auto set(bool active1, bool active2) -> core2::Status
        {
            // Исправлено: доступ через указатели
            core2::Status s = _channel1->set(active1);
            if (!s.isOk())
            {
                return s;
            }
            return _channel2->set(active2);
        }

        void off() { (void)set(false, false); }

        auto color1() -> LedChannel & { return *_channel1; }
        auto color2() -> LedChannel & { return *_channel2; }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members
        LedChannel *_channel1{nullptr};
        LedChannel *_channel2{nullptr};
    };
}

#endif