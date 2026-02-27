/// Глобальные константы приложения.
class AppConstants {
  /// IP адрес ESP8266 по умолчанию в режиме точки доступа.
  static const String defaultDeviceIp = 'http://192.168.4.1';

  /// Таймаут для обычных запросов (статус, телеметрия).
  static const Duration requestTimeout = Duration(seconds: 3);

  /// Таймаут для тяжелых операций (загрузка программы, калибровка).
  static const Duration longOperationTimeout = Duration(seconds: 10);

  /// Частота опроса телеметрии (мс).
  static const int telemetryPollingIntervalMs = 500;
}
