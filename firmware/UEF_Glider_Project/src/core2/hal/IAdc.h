#ifndef CORE2_IADC_H
#define CORE2_IADC_H

#include "../base/Result.h"

namespace core2::hal
{
    /**
     * Интерфейс АЦП (Raw Data Acquisition).
     */
    class IAdc
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~IAdc() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        IAdc() = default;
        IAdc(const IAdc &) = delete;
        auto operator=(const IAdc &) -> IAdc & = delete;
        IAdc(IAdc &&) = delete;
        auto operator=(IAdc &&) -> IAdc & = delete;

        /**
         * Чтение напряжения в милливольтах.
         * Для ESP8266 это будет обертка над ESP.getVcc().
         */
        virtual auto readMilliVolts() -> Result<uint16_t> = 0;
    };
}
#endif