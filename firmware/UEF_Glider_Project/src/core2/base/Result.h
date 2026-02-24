#ifndef CORE2_RESULT_H
#define CORE2_RESULT_H

#include <ostream>
#include <stdint.h>

namespace core2
{

    // Исправлено: performance-enum-size (экономия памяти МК)
    enum class ErrorCode : uint8_t
    {
        OK = 0,
        NOT_FOUND,
        INVALID_ARGUMENT,
        HARDWARE_FAILURE,
        BUSY,
        TIMEOUT,
        OUT_OF_MEMORY
    };

    /**
     * Хелпер для получения строкового представления ошибки.
     */
    // Исправлено: modernize-use-trailing-return-type
    inline auto errorToString(ErrorCode error) -> const char *
    {
        switch (error)
        {
        case ErrorCode::OK:
            return "OK";
        case ErrorCode::NOT_FOUND:
            return "NOT_FOUND";
        case ErrorCode::INVALID_ARGUMENT:
            return "INVALID_ARGUMENT";
        case ErrorCode::HARDWARE_FAILURE:
            return "HARDWARE_FAILURE";
        case ErrorCode::BUSY:
            return "BUSY";
        case ErrorCode::TIMEOUT:
            return "TIMEOUT";
        case ErrorCode::OUT_OF_MEMORY:
            return "OUT_OF_MEMORY";
        default:
            return "UNKNOWN_ERROR";
        }
    }

    /**
     * Перегрузка оператора для вывода в поток.
     */
    // Исправлено: modernize-use-trailing-return-type и readability-identifier-length
    inline auto operator<<(std::ostream &outStream, ErrorCode error) -> std::ostream &
    {
        return outStream << errorToString(error) << " (" << static_cast<int>(error) << ")";
    }

    template <typename T>
    class Result
    {
    public:
        Result(T value) : _value(value), _error(ErrorCode::OK), _isOk(true) {}
        Result(ErrorCode error) : _value(), _error(error), _isOk(false) {}

        // Исправлено: nodiscard и trailing return type
        [[nodiscard]] auto isOk() const -> bool { return _isOk; }
        [[nodiscard]] auto error() const -> ErrorCode { return _error; }
        [[nodiscard]] auto value() const -> T { return _value; }

    private:
        T _value;
        ErrorCode _error;
        bool _isOk;
    };

    class Status
    {
    public:
        Status(ErrorCode error = ErrorCode::OK) : _error(error) {}

        // Исправлено: nodiscard и trailing return type
        [[nodiscard]] auto isOk() const -> bool { return _error == ErrorCode::OK; }
        [[nodiscard]] auto error() const -> ErrorCode { return _error; }

        // Исправлено: modernize-return-braced-init-list
        static auto ok() -> Status { return {}; }
        static auto fail(ErrorCode err) -> Status { return {err}; }

    private:
        ErrorCode _error;
    };

} // namespace core2

#endif