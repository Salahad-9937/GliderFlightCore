/**
 * @file SystemMonitor.h
 * @brief Драйвер мониторинга ресурсов системы.
 *
 * Предоставляет отчет о состоянии RAM, FS и времени работы.
 */

#ifndef SYSTEM_MONITOR_DRIVER_H
#define SYSTEM_MONITOR_DRIVER_H

#include "../../core2/hal/ISystemInfo.h"
#include "../../core2/hal/ITimer.h"
#include "../../core2/base/Result.h"

namespace drivers
{
    class SystemMonitor
    {
    public:
        /**
         * Расширенная структура отчета (п. 7.2 Протокола - DTO).
         */
        struct HealthReport
        {
            uint32_t uptimeSec;    ///< Время работы в секундах
            uint32_t freeHeap;     ///< Свободная RAM в байтах
            uint32_t fsTotalBytes; ///< Общий объем FS в байтах
            uint32_t fsUsedBytes;  ///< Занято на FS в байтах
            uint8_t fsLoadPercent; ///< Заполнение FS в процентах (0-100)
        };

        // Исправлено: добавлен explicit и инициализация указателей
        explicit SystemMonitor(core2::hal::ISystemInfo &sys, core2::hal::ITimer &timer)
            : _sys(&sys), _timer(&timer) {}

        /**
         * Сбор актуальных метрик из HAL.
         */
        auto getReport() -> core2::Result<HealthReport>
        {
            // Исправлено: доступ через указатель
            auto statsRes = _sys->getStats();
            if (!statsRes.isOk())
            {
                return statsRes.error();
            }

            auto stats = statsRes.value();
            uint32_t uptime = _timer->now().ticks() / 1000;

            uint8_t percent = 0;
            if (stats.fsTotal > 0)
            {
                percent = static_cast<uint8_t>((stats.fsUsed * 100) / stats.fsTotal);
            }

            return HealthReport{
                uptime,
                stats.freeHeap,
                stats.fsTotal,
                stats.fsUsed,
                percent};
        }

    private:
        // Исправлено: cppcoreguidelines-avoid-const-or-ref-data-members
        core2::hal::ISystemInfo *_sys{nullptr};
        core2::hal::ITimer *_timer{nullptr};
    };
}
#endif