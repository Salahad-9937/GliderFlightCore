import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import '../../../../core/architecture/use_case.dart';
import '../../../../core/di/core_providers.dart';
import '../../domain/entities/glider_profile.dart';
import '../../domain/usecases/update_profile_name_use_case.dart';
import 'glider_profile_usecase_providers.dart';

/// Управление списком профилей через UseCases.
class GliderProfilesNotifier extends AsyncNotifier<List<GliderProfile>> {
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

final gliderProfilesNotifierProvider =
    AsyncNotifierProvider<GliderProfilesNotifier, List<GliderProfile>>(
      GliderProfilesNotifier.new,
    );

final profileByIdProvider = Provider.family<GliderProfile?, String>((ref, id) {
  final profilesAsync = ref.watch(gliderProfilesNotifierProvider);
  return profilesAsync.asData?.value.firstWhereOrNull((p) => p.id == id);
});
