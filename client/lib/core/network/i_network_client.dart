import '../architecture/failure.dart';
import '../architecture/result.dart';

/// Интерфейс универсального сетевого клиента.
///
/// Изолирует приложение от конкретной библиотеки (http, dio).
abstract interface class INetworkClient {
  /// Выполняет GET запрос.
  ///
  /// Возвращает [Result] с данными или [Failure].
  Future<Result<dynamic, Failure>> get(
    String path, {
    Map<String, String>? queryParameters,
  });

  /// Выполняет POST запрос.
  Future<Result<dynamic, Failure>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  });

  /// Выполняет потоковый запрос (для логов или длинных ответов).
  Stream<String> stream(String path, {Map<String, dynamic>? body});
}
