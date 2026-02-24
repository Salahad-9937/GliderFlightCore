#ifndef VCC_MONITOR_H
#define VCC_MONITOR_H

#include "../../core2/hal/IAdc.h"
#include "../../core2/base/Result.h"

namespace drivers
{
    /**
     * Драйвер мониторинга напряжения.
     * Теперь он "чистый": не знает про ESP8266 и может работать на любой платформе,
     * где реализован интерфейс IAdc.
     */
    class VccMonitor
    {
    public:
        // Исправлено: добавлен explicit
        explicit VccMonitor(core2::hal::IAdc &adc) : _adc(&adc) {}

        auto readVoltage() -> core2::Result<float>
        {
            // Исправлено: доступ через указатель
            auto res = _adc->readMilliVolts();
            if (!res.isOk())
            {
                return res.error();
            }

            // Логика перевода мВ в Вольты - это уровень драйвера
            // Исправлено: static_cast и заглавный суффикс литерала (readability-uppercase-literal-suffix)
            return static_cast<float>(res.value()) / 1000.0F;
        }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members
        core2::hal::IAdc *_adc{nullptr};
    };
}
#endif