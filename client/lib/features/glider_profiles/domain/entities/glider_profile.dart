/// Сущность профиля планера.
class GliderProfile {
  final String id;
  final String name;
  final String? photoPath;

  const GliderProfile({required this.id, required this.name, this.photoPath});

  /// Геттер для короткого ID (вынос из UI)
  String get shortId =>
      id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
}
