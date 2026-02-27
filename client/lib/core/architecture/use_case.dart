import 'result.dart';
import 'failure.dart';

/// Базовый интерфейс для всех сценариев использования (бизнес-логики).
///
/// [T] — тип возвращаемого значения при успехе (заменено с Type для избежания конфликта).
/// [Params] — входные параметры для выполнения сценария.
abstract interface class UseCase<T, Params> {
  /// Выполнение сценария.
  Future<Result<T, Failure>> call(Params params);
}

/// Класс-маркер для UseCase без параметров.
class NoParams {
  const NoParams();
}
