#ifndef APPLICATION_CALIBRATION_EVENTS_H
#define APPLICATION_CALIBRATION_EVENTS_H

#include "../../core2/messaging/Event.h"

namespace application::events
{
    /**
     * Состояния процесса калибровки для UI.
     */
    enum class CalibrationStatus : uint8_t
    {
        IDLE,
        WARMUP,    ///< Термостабилизация
        MEASURING, ///< Сбор данных (полный)
        ZEROING,   ///< Быстрое обнуление
        SUCCESS,   ///< Успешно завершено
        ERROR      ///< Ошибка оборудования
    };

    /**
     * Событие изменения статуса или прогресса калибровки.
     */
    struct CalibrationEvent : public core2::event::Base
    {
        static constexpr core2::EventID ID = 102;

        CalibrationStatus status;
        uint8_t progress; // 0-100%

        explicit CalibrationEvent(CalibrationStatus s, uint8_t p = 0)
            : status(s), progress(p) {}
    };
}

#endif