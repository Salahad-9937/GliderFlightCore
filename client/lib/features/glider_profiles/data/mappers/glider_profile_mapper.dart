import '../../domain/entities/glider_profile.dart';
import '../models/glider_profile_dto.dart';

/// Маппер для преобразования между DTO и доменной сущностью профиля.
class GliderProfileMapper {
  /// Преобразует DTO в чистую сущность [GliderProfile].
  static GliderProfile toEntity(GliderProfileDto dto) {
    return GliderProfile(id: dto.id, name: dto.name, photoPath: dto.photoPath);
  }

  /// Преобразует сущность [GliderProfile] в [GliderProfileDto].
  static GliderProfileDto fromEntity(GliderProfile entity) {
    return GliderProfileDto(
      id: entity.id,
      name: entity.name,
      photoPath: entity.photoPath,
    );
  }
}
