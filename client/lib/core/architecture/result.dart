import 'failure.dart';

/// Универсальный тип для обработки результатов операций.
///
/// Позволяет явно обрабатывать успех [Success] или ошибку [Error]
/// без использования исключений (try-catch) в бизнес-логике.
sealed class Result<S, F extends Failure> {
  const Result();

  /// Выполняет [onSuccess] если результат успешный, или [onError] при ошибке.
  T fold<T>(T Function(S value) onSuccess, T Function(F failure) onError) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Error(failure: final f) => onError(f),
    };
  }
}

/// Успешный результат операции.
final class Success<S, F extends Failure> extends Result<S, F> {
  /// Полученное значение.
  final S value;
  const Success(this.value);
}

/// Результат операции с ошибкой.
final class Error<S, F extends Failure> extends Result<S, F> {
  /// Объект ошибки.
  final F failure;
  const Error(this.failure);
}
