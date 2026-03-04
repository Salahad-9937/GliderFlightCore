import 'package:collection/collection.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/core_providers.dart';
import '../../domain/entities/flight_program.dart';
import '../../domain/usecases/delete_program_use_case.dart';
import '../../domain/usecases/save_program_use_case.dart';
import 'flight_program_usecase_providers.dart';

part 'flight_programs_providers.g.dart';

/// Провайдер управления списком программ.
@riverpod
class FlightPrograms extends _$FlightPrograms {
  @override
  Future<List<FlightProgram>> build(String profileId) async {
    final result = await ref.watch(getProgramsUseCaseProvider).call(profileId);

    return result.fold(
      (programs) => programs,
      (failure) => throw Exception(failure.message),
    );
  }

  /// Добавление новой программы.
  Future<void> addProgram(String name) async {
    final newProgram = FlightProgram(id: const Uuid().v4(), name: name);

    state = const AsyncLoading();

    final result = await ref
        .read(saveProgramUseCaseProvider)
        .call(SaveProgramParams(profileId: profileId, program: newProgram));

    result.fold((_) => ref.invalidateSelf(), (failure) {
      ref.read(loggerServiceProvider).e(failure.message);
      ref.invalidateSelf();
    });
  }

  /// Удаление программы.
  Future<void> deleteProgram(String programId) async {
    state = const AsyncLoading();

    final result = await ref
        .read(deleteProgramUseCaseProvider)
        .call(DeleteProgramParams(profileId: profileId, programId: programId));

    result.fold((_) => ref.invalidateSelf(), (failure) {
      ref.read(loggerServiceProvider).e(failure.message);
      ref.invalidateSelf();
    });
  }
}

/// Провайдер для получения одной программы по ID.
@riverpod
FlightProgram? programById(
  Ref ref, {
  required String profileId,
  required String programId,
}) {
  final programsAsync = ref.watch(flightProgramsProvider(profileId));
  return programsAsync.asData?.value.firstWhereOrNull((p) => p.id == programId);
}
