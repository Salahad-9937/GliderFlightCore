import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/flight_program_repository_impl.dart';
import '../../domain/usecases/delete_program_use_case.dart';
import '../../domain/usecases/get_programs_use_case.dart';
import '../../domain/usecases/save_program_use_case.dart';

/// Провайдер сценария получения программ.
final getProgramsUseCaseProvider = Provider<GetProgramsUseCase>((ref) {
  return GetProgramsUseCase(ref.watch(flightProgramRepositoryProvider));
});

/// Провайдер сценария сохранения программ.
final saveProgramUseCaseProvider = Provider<SaveProgramUseCase>((ref) {
  return SaveProgramUseCase(ref.watch(flightProgramRepositoryProvider));
});

/// Провайдер сценария удаления программ.
final deleteProgramUseCaseProvider = Provider<DeleteProgramUseCase>((ref) {
  return DeleteProgramUseCase(ref.watch(flightProgramRepositoryProvider));
});
