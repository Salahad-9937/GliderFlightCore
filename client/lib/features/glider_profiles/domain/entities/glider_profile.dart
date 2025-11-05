import 'dart:convert';

/// Сущность, представляющая профиль планера.
class GliderProfile {
  final String id;
  final String name;
  final String? photoPath;

  GliderProfile({
    required this.id,
    required this.name,
    this.photoPath,
  });

  // Методы для сериализации/десериализации в JSON
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'photoPath': photoPath,
    };
  }

  factory GliderProfile.fromMap(Map<String, dynamic> map) {
    return GliderProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      photoPath: map['photoPath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory GliderProfile.fromJson(String source) =>
      GliderProfile.fromMap(json.decode(source));
}