/// Объект передачи данных (DTO) для профиля планера.
///
/// Используется для сохранения и загрузки данных из локального JSON-файла.
class GliderProfileDto {
  final String id;
  final String name;
  final String? photoPath;

  const GliderProfileDto({
    required this.id,
    required this.name,
    this.photoPath,
  });

  /// Создает DTO из Map (JSON).
  factory GliderProfileDto.fromJson(Map<String, dynamic> json) {
    return GliderProfileDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      photoPath: json['photoPath'],
    );
  }

  /// Преобразует DTO в Map (JSON).
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'photoPath': photoPath};
  }
}
