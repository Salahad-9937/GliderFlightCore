/// Базовый класс для всех доменных ошибок системы.
abstract class Failure {
  /// Сообщение об ошибке.
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

/// Ошибка сетевого взаимодействия (таймаут, отсутствие связи).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Ошибка сети']);
}

/// Ошибка сервера (некорректный HTTP статус).
class ServerFailure extends Failure {
  /// HTTP статус код.
  final int? statusCode;
  const ServerFailure(super.message, [this.statusCode]);
}

/// Ошибка обработки данных (ошибка парсинга JSON).
class DataFailure extends Failure {
  const DataFailure(super.message);
}

/// Ошибка работы с локальным хранилищем (LittleFS или SharedPreferences).
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
