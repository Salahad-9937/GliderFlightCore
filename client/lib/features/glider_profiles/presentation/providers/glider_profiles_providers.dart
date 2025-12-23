import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import '../../data/repositories/glider_profile_repository_impl.dart';
import '../../domain/entities/glider_profile.dart';
import '../../domain/repositories/glider_profile_repository.dart';

/// Notifier для управления списком профилей планеров.
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

  /// Обновляет имя существующего профиля.
  Future<void> updateProfileName(String id, String newName) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateProfileName(id, newName);
      return _repository.getGliderProfiles();
    });
  }
}

/// Провайдер для Notifier-а списка профилей.
final gliderProfilesNotifierProvider =
    AsyncNotifierProvider<GliderProfilesNotifier, List<GliderProfile>>(
  GliderProfilesNotifier.new,
);

/// Провайдер для получения одного профиля по его ID.
final profileByIdProvider = Provider.family<GliderProfile?, String>((ref, id) {
  final profilesAsyncValue = ref.watch(gliderProfilesNotifierProvider);
  final data = profilesAsyncValue.asData;
  if (data != null) {
    return data.value.firstWhereOrNull((p) => p.id == id);
  }
  return null;
});