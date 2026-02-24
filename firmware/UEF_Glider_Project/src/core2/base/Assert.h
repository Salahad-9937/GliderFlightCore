#ifndef CORE2_ASSERT_H
#define CORE2_ASSERT_H

#include "ILogger.h"

/**
 * Система критических проверок (п. 10.1 Протокола - Защита периметра).
 * Используется макрос для захвата __FILE__ в месте вызова.
 * Реализован через do-while(0) для безопасности в if-else блоках.
 */
namespace core2
{

// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define CORE2_ASSERT(condition, logger, message)                              \
    do                                                                        \
    {                                                                         \
        if (!(condition))                                                     \
        {                                                                     \
            (logger).error("КРИТИЧЕСКАЯ ОШИБКА: ");                           \
            (logger).error((message));                                        \
            (logger).error(" Файл: " __FILE__);                               \
            /* Тут может быть вызов системного сброса или бесконечный цикл */ \
        }                                                                     \
    } while (0)

} // namespace core2

#endif