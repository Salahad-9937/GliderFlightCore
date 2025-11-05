import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
// collection используется для безопасного поиска в списке
import 'package:collection/collection.dart';

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
    state = const AsyncValue.loading();
    final newProfile = GliderProfile(id: const Uuid().v4(), name: name);
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


/// Провайдер для получения одного профиля по его ID.
///
/// Использует `.family` для передачи параметра (ID).
/// Зависит от основного списка профилей и находит в нем нужный.
final profileByIdProvider = Provider.family<GliderProfile?, String>((ref, id) {
  // Следим за состоянием основного списка
  final profilesAsyncValue = ref.watch(gliderProfilesNotifierProvider);
  // Используем .asData для безопасного извлечения данных
  final data = profilesAsyncValue.asData;
  // Если данные есть (не загрузка и не ошибка), ищем в них профиль по ID
  if (data != null) {
    return data.value.firstWhereOrNull((p) => p.id == id);
  }
  // В противном случае (загрузка/ошибка) возвращаем null
  return null;
});