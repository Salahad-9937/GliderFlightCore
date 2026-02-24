#ifndef ESP8266_PLATFORM_H
#define ESP8266_PLATFORM_H

#include <Arduino.h>
#include <Wire.h>
#include <Servo.h>
#include <ESP8266WiFi.h>
#include <LittleFS.h>

#include "../../core2/hal/II2c.h"
#include "../../core2/hal/IGpio.h"
#include "../../core2/hal/IActuator.h"
#include "../../core2/hal/INetwork.h"
#include "../../core2/hal/IAdc.h"
#include "../../core2/hal/IWatchdog.h"
#include "../../core2/hal/ITimer.h"
#include "../../core2/hal/ILock.h"
#include "../../core2/hal/ISystemInfo.h"
#include "../../core2/base/ILogger.h"

namespace core2::platform
{
    /**
     * Timer Bridge.
     * Источник системного времени для планировщика и таймингов.
     */
    class Esp8266Timer : public hal::ITimer
    {
    public:
        auto now() -> Timestamp override { return Timestamp(millis()); }
        void delay(Duration duration) override { ::delay(duration.toMs()); }
    };

    /**
     * Lock Bridge.
     * Реализация критической секции через глобальный запрет прерываний.
     */
    class Esp8266Lock : public hal::ILock
    {
    public:
        void lock() override { noInterrupts(); }
        void unlock() override { interrupts(); }
    };

    /**
     * I2C Bridge. Транспорт байт через Wire.
     */
    class ArduinoI2c : public hal::II2c
    {
    public:
        void init(uint8_t sda, uint8_t scl) { Wire.begin(sda, scl); }

        auto write(uint8_t address, const uint8_t *data, size_t size) -> Status override
        {
            Wire.beginTransmission(address);
            Wire.write(data, size);
            return (Wire.endTransmission() == 0) ? Status::ok() : Status::fail(ErrorCode::HARDWARE_FAILURE);
        }

        auto read(uint8_t address, uint8_t *buffer, size_t size) -> Status override
        {
            if (Wire.requestFrom(address, (uint8_t)size) != size)
            {
                return Status::fail(ErrorCode::HARDWARE_FAILURE);
            }
            for (size_t i = 0; i < size; i++)
            {
                buffer[i] = Wire.read();
            }
            return Status::ok();
        }
    };

    /**
     * GPIO Input Bridge.
     */
    class DigitalInput : public hal::IDigitalInput
    {
    public:
        DigitalInput(uint8_t pin) : _pin(pin) { pinMode(_pin, INPUT_PULLUP); }
        auto read() -> Result<bool> override { return (digitalRead(_pin) == HIGH); }

    private:
        uint8_t _pin;
    };

    /**
     * GPIO Output Bridge.
     */
    class DigitalOutput : public hal::IDigitalOutput
    {
    public:
        DigitalOutput(uint8_t pin) : _pin(pin) { pinMode(_pin, OUTPUT); }
        auto write(bool level) -> Status override
        {
            digitalWrite(_pin, level ? HIGH : LOW);
            return Status::ok();
        }

    private:
        uint8_t _pin;
    };

    /**
     * Actuator Bridge (Servo).
     */
    class ServoActuator : public hal::IActuator
    {
    public:
        ServoActuator(uint8_t pin) : _pin(pin) { _servo.attach(_pin); }
        auto setValue(int16_t value) -> Status override
        {
            _servo.write(value);
            return Status::ok();
        }

    private:
        Servo _servo;
        uint8_t _pin;
    };

    /**
     * Network Power Bridge.
     */
    class Esp8266Network : public hal::INetwork
    {
    public:
        auto setPower(bool on) -> Status override
        {
            if (on)
            {
                WiFi.forceSleepWake();
                delay(1);
            }
            else
            {
                WiFi.mode(WIFI_OFF);
                WiFi.forceSleepBegin();
                delay(1);
            }
            return Status::ok();
        }
        auto isPowered() -> bool override { return WiFi.getMode() != WIFI_OFF; }
    };

    /**
     * ADC Bridge (VCC).
     */
    class Esp8266Adc : public hal::IAdc
    {
    public:
        auto readMilliVolts() -> Result<uint16_t> override { return (uint16_t)ESP.getVcc(); }
    };

    /**
     * Watchdog Bridge.
     */
    class Esp8266Watchdog : public hal::IWatchdog
    {
    public:
        auto begin(uint32_t timeoutMs) -> Status override
        {
            ESP.wdtEnable(timeoutMs);
            return Status::ok();
        }
        void kick() override { ESP.wdtFeed(); }
    };

    /**
     * System Info Bridge.
     */
    class Esp8266SystemInfo : public hal::ISystemInfo
    {
    public:
        auto getStats() -> Result<hal::SysStats> override
        {
            FSInfo fs_info;
            if (!LittleFS.info(fs_info))
            {
                return ErrorCode::HARDWARE_FAILURE;
            }

            return hal::SysStats{
                ESP.getFreeHeap(),
                (uint32_t)fs_info.totalBytes,
                (uint32_t)fs_info.usedBytes};
        }
    };

    /**
     * Logger Sink.
     */
    class SerialSink : public ILogger
    {
    public:
        void info(const char *msg) override { Serial.print(msg); }
        void error(const char *msg) override { Serial.print(msg); }
        void debug(const char *msg) override { Serial.print(msg); }
    };
}
#endif