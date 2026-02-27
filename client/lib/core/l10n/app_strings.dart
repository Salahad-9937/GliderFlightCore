/// Контейнер для строк приложения.
///
/// Позволяет централизованно управлять текстами и легко добавить перевод.
class AppStrings {
  final String appTitle;
  final String connectionStatus;
  final String telemetry;
  final String settings;
  final String error;

  const AppStrings({
    required this.appTitle,
    required this.connectionStatus,
    required this.telemetry,
    required this.settings,
    required this.error,
  });

  static const ru = AppStrings(
    appTitle: 'Glider Flight Core',
    connectionStatus: 'Статус подключения',
    telemetry: 'Телеметрия',
    settings: 'Настройки',
    error: 'Ошибка',
  );
}
