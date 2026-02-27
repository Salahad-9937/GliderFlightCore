import 'dart:developer' as dev;
import 'i_logger_service.dart';

/// Реализация логгера для вывода в системную консоль Flutter.
class LoggerServiceImpl extends ILoggerService {
  @override
  void log(
    LogLevel level,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    final time = DateTime.now().toIso8601String().split('T').last;
    final label = level.name.toUpperCase();

    dev.log(
      '[$time] $label: $message',
      name: 'GLIDER_APP',
      error: error,
      stackTrace: stackTrace,
      level: _getPriority(level),
    );
  }

  int _getPriority(LogLevel level) {
    return switch (level) {
      LogLevel.debug => 500,
      LogLevel.info => 800,
      LogLevel.warning => 900,
      LogLevel.error => 1000,
    };
  }
}
