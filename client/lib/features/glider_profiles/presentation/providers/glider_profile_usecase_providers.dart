import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/glider_profile_repository_impl.dart';
import '../../domain/usecases/delete_glider_profile_use_case.dart';
import '../../domain/usecases/get_glider_profiles_use_case.dart';
import '../../domain/usecases/save_glider_profile_use_case.dart';
import '../../domain/usecases/update_profile_name_use_case.dart';

final getGliderProfilesUseCaseProvider = Provider<GetGliderProfilesUseCase>((
  ref,
) {
  return GetGliderProfilesUseCase(ref.watch(gliderProfileRepositoryProvider));
});

final saveGliderProfileUseCaseProvider = Provider<SaveGliderProfileUseCase>((
  ref,
) {
  return SaveGliderProfileUseCase(ref.watch(gliderProfileRepositoryProvider));
});

final deleteGliderProfileUseCaseProvider = Provider<DeleteGliderProfileUseCase>(
  (ref) {
    return DeleteGliderProfileUseCase(
      ref.watch(gliderProfileRepositoryProvider),
    );
  },
);

final updateProfileNameUseCaseProvider = Provider<UpdateProfileNameUseCase>((
  ref,
) {
  return UpdateProfileNameUseCase(ref.watch(gliderProfileRepositoryProvider));
});
