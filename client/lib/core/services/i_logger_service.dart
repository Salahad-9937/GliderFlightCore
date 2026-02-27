/// Уровни важности логов.
enum LogLevel { debug, info, warning, error }

/// Интерфейс службы логирования.
///
/// Необходим для отслеживания состояния связи с ESP8266 и ошибок парсинга.
abstract class ILoggerService {
  /// Записывает сообщение в лог.
  void log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]);

  void d(String message) => log(LogLevel.debug, message);
  void i(String message) => log(LogLevel.info, message);
  void w(String message) => log(LogLevel.warning, message);
  void e(String message, [Object? error, StackTrace? stackTrace]) =>
      log(LogLevel.error, message, error, stackTrace);
}
