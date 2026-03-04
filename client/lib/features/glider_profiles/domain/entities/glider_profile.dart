/// Сущность профиля планера.
///
/// Чистая доменная модель, содержащая логику идентификации и представления данных.
class GliderProfile {
  final String id;
  final String name;
  final String? photoPath;

  const GliderProfile({required this.id, required this.name, this.photoPath});

  /// Геттер для короткого ID (первые 8 символов).
  String get shortId =>
      id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();

  /// Геттер для символа аватара (первая буква имени).
  String get avatarLabel => name.isNotEmpty ? name[0].toUpperCase() : '?';

  /// Проверка наличия имени.
  bool get hasValidName => name.trim().isNotEmpty;
}
