#include "Registry.h"

namespace core2
{
    // Определение статических указателей в единственном экземпляре
    ILogger* Registry::_logger = nullptr;
    hal::ILock* Registry::_lock = nullptr;
}