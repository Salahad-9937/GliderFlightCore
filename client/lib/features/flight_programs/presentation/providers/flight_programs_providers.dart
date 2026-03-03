import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// Контроллер управления списком полетных программ (Presentation Layer).
///
/// Отвечает только за вызов соответствующих сценариев использования
/// и уведомление UI об изменениях.
class FlightProgramsController {
  final Ref _ref;
  FlightProgramsController(this._ref);

  /// Команда добавления новой программы.
  /// Генерация сущности делегирована ниже (в репозиторий или usecase).
  Future<void> addProgram(String profileId, String name) async {
    // В данном проекте ID генерируется на клиенте для оффлайн-работы.
    // Оставляем создание объекта здесь, но логика "как сохранять" скрыта.
    final newProgram = FlightProgram(
      id: DateTime.now().millisecondsSinceEpoch
          .toString(), // Временное решение до переноса в UseCase
      name: name,
    );

    final result = await _ref
        .read(saveProgramUseCaseProvider)
        .call(SaveProgramParams(profileId: profileId, program: newProgram));

    result.fold(
      (_) => _ref.invalidate(flightProgramsProvider(profileId)),
      (failure) => _ref.read(loggerServiceProvider).e(failure.message),
    );
  }

  Future<void> deleteProgram(String profileId, String programId) async {
    final result = await _ref
        .read(deleteProgramUseCaseProvider)
        .call(DeleteProgramParams(profileId: profileId, programId: programId));

    result.fold(
      (_) => _ref.invalidate(flightProgramsProvider(profileId)),
      (failure) => _ref.read(loggerServiceProvider).e(failure.message),
    );
  }
}

final flightProgramsControllerProvider = Provider<FlightProgramsController>((
  ref,
) {
  return FlightProgramsController(ref);
});

final programByIdProvider = Provider.family<FlightProgram?, ProgramId>((
  ref,
  id,
) {
  final programsAsync = ref.watch(flightProgramsProvider(id.profileId));
  return programsAsync.asData?.value.firstWhereOrNull(
    (p) => p.id == id.programId,
  );
});
