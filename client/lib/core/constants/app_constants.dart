/// Глобальные константы приложения.
class AppConstants {
  static const String defaultDeviceIp = 'http://192.168.4.1';
  static const Duration requestTimeout = Duration(seconds: 3);
  static const Duration longOperationTimeout = Duration(seconds: 10);
  static const int telemetryPollingIntervalMs = 500;

  /// Максимальное количество последовательных ошибок связи до разрыва соединения.
  static const int maxConsecutiveFailures = 3;
}
