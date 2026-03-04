import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/glider_profile_repository_impl.dart';
import '../../domain/usecases/delete_glider_profile_use_case.dart';
import '../../domain/usecases/get_glider_profiles_use_case.dart';
import '../../domain/usecases/save_glider_profile_use_case.dart';
import '../../domain/usecases/update_profile_name_use_case.dart';

part 'glider_profile_usecase_providers.g.dart';

@riverpod
GetGliderProfilesUseCase getGliderProfilesUseCase(Ref ref) {
  return GetGliderProfilesUseCase(ref.watch(gliderProfileRepositoryProvider));
}

@riverpod
SaveGliderProfileUseCase saveGliderProfileUseCase(Ref ref) {
  return SaveGliderProfileUseCase(ref.watch(gliderProfileRepositoryProvider));
}

@riverpod
DeleteGliderProfileUseCase deleteGliderProfileUseCase(Ref ref) {
  return DeleteGliderProfileUseCase(ref.watch(gliderProfileRepositoryProvider));
}

@riverpod
UpdateProfileNameUseCase updateProfileNameUseCase(Ref ref) {
  return UpdateProfileNameUseCase(ref.watch(gliderProfileRepositoryProvider));
}
