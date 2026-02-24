#ifndef CORE2_ISYSTEM_INFO_H
#define CORE2_ISYSTEM_INFO_H

#include "../base/Result.h"
#include <stdint.h>

namespace core2::hal
{
    /**
     * Структура системных метрик.
     */
    struct SysStats
    {
        uint32_t freeHeap; // Свободная RAM (байты)
        uint32_t fsTotal;  // Общий объем FS (байты)
        uint32_t fsUsed;   // Занято на FS (байты)
    };

    /**
     * Интерфейс получения данных о состоянии железа.
     */
    class ISystemInfo
    {
    public:
        // Исправлено: modernize-use-equals-default
        virtual ~ISystemInfo() = default;

        // Исправлено: cppcoreguidelines-special-member-functions (Rule of 5)
        ISystemInfo() = default;
        ISystemInfo(const ISystemInfo &) = delete;
        auto operator=(const ISystemInfo &) -> ISystemInfo & = delete;
        ISystemInfo(ISystemInfo &&) = delete;
        auto operator=(ISystemInfo &&) -> ISystemInfo & = delete;

        virtual auto getStats() -> Result<SysStats> = 0;
    };
} // namespace core2::hal
#endif