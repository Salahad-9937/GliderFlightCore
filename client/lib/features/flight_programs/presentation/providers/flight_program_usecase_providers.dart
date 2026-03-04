import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/flight_program_repository_impl.dart';
import '../../domain/usecases/delete_program_use_case.dart';
import '../../domain/usecases/get_programs_use_case.dart';
import '../../domain/usecases/save_program_use_case.dart';

part 'flight_program_usecase_providers.g.dart';

/// Провайдер сценария получения программ.
@riverpod
GetProgramsUseCase getProgramsUseCase(Ref ref) {
  return GetProgramsUseCase(ref.watch(flightProgramRepositoryProvider));
}

/// Провайдер сценария сохранения программ.
@riverpod
SaveProgramUseCase saveProgramUseCase(Ref ref) {
  return SaveProgramUseCase(ref.watch(flightProgramRepositoryProvider));
}

/// Провайдер сценария удаления программ.
@riverpod
DeleteProgramUseCase deleteProgramUseCase(Ref ref) {
  return DeleteProgramUseCase(ref.watch(flightProgramRepositoryProvider));
}
