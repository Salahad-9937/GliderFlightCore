import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/glider_profile_repository_impl.dart';
import '../../domain/entities/glider_profile.dart';
import '../../domain/repositories/glider_profile_repository.dart';

/// Notifier для управления списком профилей планеров.
///
/// Обрабатывает загрузку, добавление и удаление профилей.
class GliderProfilesNotifier extends AsyncNotifier<List<GliderProfile>> {
  GliderProfileRepository get _repository => ref.read(gliderProfileRepositoryProvider);

  @override
  Future<List<GliderProfile>> build() async {
    return _repository.getGliderProfiles();
  }

  /// Добавляет новый профиль.
  Future<void> addProfile(String name) async {
    // Устанавливаем состояние "загрузка", сохраняя предыдущие данные
    state = const AsyncValue.loading();
    // Создаем новый профиль с уникальным ID
    final newProfile = GliderProfile(id: const Uuid().v4(), name: name);
    // Оборачиваем в AsyncValue.guard для автоматической обработки ошибок
    state = await AsyncValue.guard(() async {
      await _repository.saveGliderProfile(newProfile);
      return _repository.getGliderProfiles();
    });
  }

  /// Удаляет профиль.
  Future<void> deleteProfile(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteGliderProfile(id);
      return _repository.getGliderProfiles();
    });
  }
}

/// Провайдер для Notifier-а, управляющего профилями планеров.
final gliderProfilesNotifierProvider =
    AsyncNotifierProvider<GliderProfilesNotifier, List<GliderProfile>>(
  GliderProfilesNotifier.new,
);