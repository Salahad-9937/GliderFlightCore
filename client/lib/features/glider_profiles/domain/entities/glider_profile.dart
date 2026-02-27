/// Сущность профиля планера.
///
/// Чистая доменная модель, содержащая только данные.
class GliderProfile {
  final String id;
  final String name;
  final String? photoPath;

  const GliderProfile({required this.id, required this.name, this.photoPath});
}
