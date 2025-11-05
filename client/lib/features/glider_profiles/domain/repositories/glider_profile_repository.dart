import '../entities/glider_profile.dart';

/// Абстрактный репозиторий для управления профилями планеров.
abstract class GliderProfileRepository {
  /// Возвращает список всех профилей.
  Future<List<GliderProfile>> getGliderProfiles();

  /// Сохраняет (добавляет или обновляет) профиль.
  Future<void> saveGliderProfile(GliderProfile profile);

  /// Удаляет профиль по его ID.
  Future<void> deleteGliderProfile(String id);
}