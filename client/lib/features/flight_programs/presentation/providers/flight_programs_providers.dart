import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/di/core_providers.dart';
import '../../domain/entities/flight_program.dart';
import '../../domain/usecases/delete_program_use_case.dart';
import '../../domain/usecases/save_program_use_case.dart';
import 'flight_program_usecase_providers.dart';
import 'program_id_provider.dart';

/// Провайдер списка программ для конкретного профиля.
final flightProgramsProvider =
    FutureProvider.family<List<FlightProgram>, String>((ref, profileId) async {
      final result = await ref
          .watch(getProgramsUseCaseProvider)
          .call(profileId);

      return result.fold(
        (programs) => programs,
        (failure) => throw Exception(failure.message),
      );
    });

/// Контроллер управления полетными программами.
class FlightProgramsController {
  final Ref _ref;
  FlightProgramsController(this._ref);

  /// Добавляет новую программу.
  Future<void> addProgram(String profileId, String name) async {
    final newProgram = FlightProgram(id: const Uuid().v4(), name: name);

    final result = await _ref
        .read(saveProgramUseCaseProvider)
        .call(SaveProgramParams(profileId: profileId, program: newProgram));

    result.fold(
      (_) => _ref.invalidate(flightProgramsProvider(profileId)),
      (failure) => _ref
          .read(loggerServiceProvider)
          .e('Ошибка создания программы: ${failure.message}'),
    );
  }

  /// Удаляет программу.
  Future<void> deleteProgram(String profileId, String programId) async {
    final result = await _ref
        .read(deleteProgramUseCaseProvider)
        .call(DeleteProgramParams(profileId: profileId, programId: programId));

    result.fold(
      (_) => _ref.invalidate(flightProgramsProvider(profileId)),
      (failure) => _ref
          .read(loggerServiceProvider)
          .e('Ошибка удаления программы: ${failure.message}'),
    );
  }

  /// Обновляет существующую программу.
  Future<void> updateProgram(String profileId, FlightProgram program) async {
    final result = await _ref
        .read(saveProgramUseCaseProvider)
        .call(SaveProgramParams(profileId: profileId, program: program));

    result.fold(
      (_) => _ref.invalidate(flightProgramsProvider(profileId)),
      (failure) => _ref
          .read(loggerServiceProvider)
          .e('Ошибка обновления программы: ${failure.message}'),
    );
  }
}

final flightProgramsControllerProvider = Provider<FlightProgramsController>((
  ref,
) {
  return FlightProgramsController(ref);
});

/// Провайдер для получения одной программы по ID.
final programByIdProvider = Provider.family<FlightProgram?, ProgramId>((
  ref,
  id,
) {
  final programsAsync = ref.watch(flightProgramsProvider(id.profileId));
  return programsAsync.asData?.value.firstWhereOrNull(
    (p) => p.id == id.programId,
  );
});
