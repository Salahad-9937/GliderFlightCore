import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/architecture/use_case.dart';
import '../../../../core/di/core_providers.dart';
import '../../domain/entities/glider_profile.dart';
import '../../domain/usecases/update_profile_name_use_case.dart';
import 'glider_profile_usecase_providers.dart';

part 'glider_profiles_providers.g.dart';

/// Управление списком профилей через UseCases.
@riverpod
class GliderProfiles extends _$GliderProfiles {
  @override
  Future<List<GliderProfile>> build() async {
    final result = await ref
        .watch(getGliderProfilesUseCaseProvider)
        .call(const NoParams());
    return result.fold(
      (list) => list,
      (failure) => throw Exception(failure.message),
    );
  }

  Future<void> addProfile(String name) async {
    state = const AsyncLoading();
    final newProfile = GliderProfile(id: const Uuid().v4(), name: name);

    final result = await ref
        .read(saveGliderProfileUseCaseProvider)
        .call(newProfile);

    result.fold(
      (_) => ref.invalidateSelf(),
      (failure) => ref
          .read(loggerServiceProvider)
          .e('Ошибка добавления профиля: ${failure.message}'),
    );
  }

  Future<void> deleteProfile(String id) async {
    state = const AsyncLoading();
    final result = await ref.read(deleteGliderProfileUseCaseProvider).call(id);

    result.fold(
      (_) => ref.invalidateSelf(),
      (failure) => ref
          .read(loggerServiceProvider)
          .e('Ошибка удаления профиля: ${failure.message}'),
    );
  }

  Future<void> updateProfileName(String id, String newName) async {
    state = const AsyncLoading();
    final result = await ref
        .read(updateProfileNameUseCaseProvider)
        .call(UpdateProfileNameParams(id: id, newName: newName));

    result.fold(
      (_) => ref.invalidateSelf(),
      (failure) => ref
          .read(loggerServiceProvider)
          .e('Ошибка переименования профиля: ${failure.message}'),
    );
  }
}

/// Провайдер для получения профиля по ID.
@riverpod
GliderProfile? profileById(Ref ref, String id) {
  final profilesAsync = ref.watch(gliderProfilesProvider);
  return profilesAsync.asData?.value.firstWhereOrNull((p) => p.id == id);
}
