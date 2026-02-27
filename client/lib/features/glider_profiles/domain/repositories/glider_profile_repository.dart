import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../entities/glider_profile.dart';

/// Интерфейс репозитория для управления профилями планеров.
abstract interface class IGliderProfileRepository {
  /// Возвращает список всех профилей.
  Future<Result<List<GliderProfile>, Failure>> getGliderProfiles();

  /// Сохраняет (добавляет или обновляет) профиль.
  Future<Result<void, Failure>> saveGliderProfile(GliderProfile profile);

  /// Удаляет профиль по его ID.
  Future<Result<void, Failure>> deleteGliderProfile(String id);

  /// Обновляет имя профиля.
  Future<Result<void, Failure>> updateProfileName(String id, String newName);
}
