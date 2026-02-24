/**
 * UEF 2.0: ЭТАП 1 - ТЕСТ ВВОДА И ИНДИКАЦИИ
 */

#include <Arduino.h>
#include "src/core2/Config.h"
#include "src/core2/base/Registry.h"
#include "src/core2/base/BufferedLogger.h"
#include "src/core2/messaging/EventBus.h"
#include "src/platforms/esp8266/Esp8266Platform.h"
#include "src/presentation/input/HallSensorHandler.h"

using namespace core2;
using namespace application::events;

// Глобальные компоненты инфраструктуры
platform::SerialSink serialSink;
BufferedLogger asyncLogger;
EventBus<> globalBus;

// HAL объекты
platform::DigitalInput hallPin(config::DEFAULT_HW_MAP.pinHall);
platform::DigitalOutput ledPin(config::DEFAULT_HW_MAP.pinLed1);

// Презентационный слой
presentation::input::HallSensorHandler hallHandler(hallPin, globalBus);

/**
 * Слушатель событий Холла для теста.
 */
class TestInputListener : public TypedEventListener<HallEvent>
{
public:
    void onTypedEvent(const HallEvent &e) override
    {
        char buf[64];
        switch (e.gesture)
        {
        case HallGesture::CLICK:
            Registry::getLogger().info("INPUT: Одиночный клик\n");
            ledPin.write(true); // Включаем LED на клик
            break;
        case HallGesture::DOUBLE_CLICK:
            Registry::getLogger().info("INPUT: Двойной клик\n");
            ledPin.write(false); // Выключаем LED на двойной клик
            break;
        case HallGesture::LONG_PRESS_START:
            Registry::getLogger().info("INPUT: Удержание (Long Press)\n");
            break;
        case HallGesture::RELEASE:
            snprintf(buf, sizeof(buf), "INPUT: Отпущено (Длительность: %u мс)\n", e.duration);
            Registry::getLogger().info(buf);
            break;
        }
    }
};

TestInputListener inputObserver;

void setup()
{
    Serial.begin(config::DEFAULT_HW_MAP.baudRate);
    delay(1000);

    // Инициализация ядра
    Registry::injectLogger(&asyncLogger);

    // Подписка на события
    globalBus.subscribe(&inputObserver);

    asyncLogger.info("--- UEF 2.0 Stage 1: Input Test ---\n");
    asyncLogger.info("Используйте магнит для проверки датчика Холла.\n");
}

void loop()
{
    uint32_t now = millis();

    // Обновление логики ввода
    hallHandler.update(now);

    // Сброс логов в Serial (неблокирующий)
    asyncLogger.flush(serialSink, 128);
}