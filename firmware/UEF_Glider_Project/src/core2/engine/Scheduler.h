#ifndef CORE2_SCHEDULER_H
#define CORE2_SCHEDULER_H

#include <stdint.h>
#include <stddef.h>
#include <array>
#include "../Config.h"

namespace core2
{

    /**
     * Интерфейс периодической задачи.
     */
    class ITask
    {
    public:
        virtual ~ITask() = default;

        ITask() = default;
        ITask(const ITask &) = delete;
        auto operator=(const ITask &) -> ITask & = delete;
        ITask(ITask &&) = delete;
        auto operator=(ITask &&) -> ITask & = delete;

        virtual auto execute(uint32_t now) -> void = 0;
    };

    /**
     * Кооперативный планировщик задач.
     * Использует статическую память (std::array) и фиксированные интервалы.
     */
    template <size_t MAX_TASKS = config::MAX_TASKS>
    class Scheduler
    {
    public:
        struct TaskSlot
        {
            ITask *task;
            uint32_t interval;
            uint32_t lastRun;
            bool invoked;

            // Исправлено: описательные имена параметров и подавление swappable-parameters
            // NOLINTNEXTLINE(bugprone-easily-swappable-parameters)
            TaskSlot(ITask *taskPtr = nullptr, uint32_t intervalMs = 0, uint32_t lastRunMs = 0, bool isInvoked = false)
                : task(taskPtr), interval(intervalMs), lastRun(lastRunMs), invoked(isInvoked) {}
        };

        Scheduler() = default;

        // Исправлено: добавлен [[nodiscard]] для контроля лимита задач
        [[nodiscard]] auto addTask(ITask *task, uint32_t intervalMs) -> bool
        {
            if (_tasksCount >= MAX_TASKS)
            {
                return false;
            }

            // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
            _slots[_tasksCount] = TaskSlot{task, intervalMs, 0, false};
            _tasksCount++;
            return true;
        }

        auto run(uint32_t now) -> void
        {
            for (size_t i = 0; i < _tasksCount; i++)
            {
                // NOLINTNEXTLINE(cppcoreguidelines-pro-bounds-constant-array-index)
                TaskSlot &slot = _slots[i];

                if (slot.task == nullptr)
                {
                    continue;
                }

                bool shouldRun = (!slot.invoked) || (now - slot.lastRun >= slot.interval);

                if (shouldRun)
                {
                    slot.lastRun = now;
                    slot.invoked = true;
                    slot.task->execute(now);
                }
            }
        }

    private:
        std::array<TaskSlot, MAX_TASKS> _slots{};
        size_t _tasksCount{0};
    };

} // namespace core2

#endif