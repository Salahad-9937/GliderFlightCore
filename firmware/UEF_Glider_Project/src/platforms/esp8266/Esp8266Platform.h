#ifndef ESP8266_PLATFORM_H
#define ESP8266_PLATFORM_H

#include <Arduino.h>
#include <Wire.h>
#include <Servo.h>
#include <ESP8266WiFi.h>
#include <LittleFS.h>
#include <Adafruit_BMP085.h>

#include "../../core2/hal/II2c.h"
#include "../../core2/hal/IGpio.h"
#include "../../core2/hal/IActuator.h"
#include "../../core2/hal/INetwork.h"
#include "../../core2/hal/IAdc.h"
#include "../../core2/hal/IWatchdog.h"
#include "../../core2/hal/ITimer.h"
#include "../../core2/hal/ILock.h"
#include "../../core2/hal/ISystemInfo.h"
#include "../../core2/hal/IBarometer.h"
#include "../../core2/base/ILogger.h"

namespace core2::platform
{
    /**
     * Timer Bridge.
     */
    class Esp8266Timer : public hal::ITimer
    {
    public:
        auto now() -> Timestamp override { return Timestamp(millis()); }
        void delay(Duration duration) override { ::delay(duration.toMs()); }
    };

    /**
     * Lock Bridge.
     */
    class Esp8266Lock : public hal::ILock
    {
    public:
        void lock() override { noInterrupts(); }
        void unlock() override { interrupts(); }
    };

    /**
     * I2C Bridge.
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
     * Barometer Bridge (BMP180).
     * Реализация через библиотеку Adafruit.
     */
    class Esp8266Barometer : public hal::IBarometer
    {
    public:
        auto begin() -> Status override
        {
            return _bmp.begin(BMP085_ULTRAHIGHRES) ? Status::ok() : Status::fail(ErrorCode::HARDWARE_FAILURE);
        }

        auto readPressure() -> Result<int32_t> override
        {
            return static_cast<int32_t>(_bmp.readPressure());
        }

        auto readTemperature() -> Result<float> override
        {
            return _bmp.readTemperature();
        }

        auto readCalibrationData() -> Result<hal::Bmp180Calibration> override
        {
            hal::Bmp180Calibration c;
            Wire.beginTransmission(0x77);
            Wire.write(0xAA);
            if (Wire.endTransmission() != 0)
                return ErrorCode::HARDWARE_FAILURE;
            if (Wire.requestFrom(0x77, 22) != 22)
                return ErrorCode::HARDWARE_FAILURE;

            auto read16 = []()
            { return (int16_t)((Wire.read() << 8) | Wire.read()); };
            auto readU16 = []()
            { return (uint16_t)((Wire.read() << 8) | Wire.read()); };

            c.ac1 = read16();
            c.ac2 = read16();
            c.ac3 = read16();
            c.ac4 = readU16();
            c.ac5 = readU16();
            c.ac6 = readU16();
            c.b1 = read16();
            c.b2 = read16();
            c.mb = read16();
            c.mc = read16();
            c.md = read16();
            return c;
        }

        auto startRawTemperature() -> Status override
        {
            Wire.beginTransmission(0x77);
            Wire.write(0xF4);
            Wire.write(0x2E);
            return (Wire.endTransmission() == 0) ? Status::ok() : Status::fail(ErrorCode::HARDWARE_FAILURE);
        }

        auto startRawPressure(uint8_t oss) -> Status override
        {
            Wire.beginTransmission(0x77);
            Wire.write(0xF4);
            Wire.write(0x34 + (oss << 6));
            return (Wire.endTransmission() == 0) ? Status::ok() : Status::fail(ErrorCode::HARDWARE_FAILURE);
        }

        auto readRawResult() -> Result<uint32_t> override
        {
            Wire.beginTransmission(0x77);
            Wire.write(0xF6);
            if (Wire.endTransmission() != 0)
                return ErrorCode::HARDWARE_FAILURE;
            if (Wire.requestFrom(0x77, 3) != 3)
                return ErrorCode::HARDWARE_FAILURE;
            uint32_t res = ((uint32_t)Wire.read() << 16) | ((uint32_t)Wire.read() << 8) | (uint32_t)Wire.read();
            return res >> 8;
        }

    private:
        Adafruit_BMP085 _bmp;
    };

    /**
     * GPIO Input Bridge.
     */
    class DigitalInput : public hal::IDigitalInput
    {
    public:
        DigitalInput(uint8_t pin) : _pin(pin) { pinMode(_pin, INPUT_PULLUP); }
        auto read() -> Result<bool> override { return (digitalRead(_pin) == LOW); }

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
     * Настроен на работу с SG90 (500-2400 мкс).
     */
    class ServoActuator : public hal::IActuator
    {
    public:
        ServoActuator(uint8_t pin) : _pin(pin)
        {
            // Установка лимитов согласно даташиту SG90 для обеспечения хода 180 градусов
            _servo.attach(_pin, 500, 2400);
        }

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