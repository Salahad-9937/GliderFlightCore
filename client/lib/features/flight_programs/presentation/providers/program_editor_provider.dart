import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/flight_program.dart';
import '../../domain/entities/flight_program_step.dart';
import '../../domain/usecases/save_program_use_case.dart';
import 'flight_program_usecase_providers.dart';
import 'flight_programs_providers.dart';
import 'program_id_provider.dart';

part 'program_editor_provider.g.dart';

/// Состояние редактора полетной программы.
final class ProgramEditorState {
  final FlightProgram? program;
  final bool hasChanges;
  final String? profileId;

  const ProgramEditorState({
    this.program,
    this.hasChanges = false,
    this.profileId,
  });

  ProgramEditorState copyWith({
    FlightProgram? program,
    bool? hasChanges,
    String? profileId,
  }) {
    return ProgramEditorState(
      program: program ?? this.program,
      hasChanges: hasChanges ?? this.hasChanges,
      profileId: profileId ?? this.profileId,
    );
  }
}

/// Контроллер управления состоянием текущей редактируемой программы.
@riverpod
class ProgramEditor extends _$ProgramEditor {
  @override
  ProgramEditorState build() => const ProgramEditorState();

  /// Инициализация редактора данными программы.
  void init(String profileId, String programId) {
    if (state.program != null && state.program!.id == programId) return;

    final programIdObj = ProgramId(profileId: profileId, programId: programId);
    final initialProgram = ref.read(programByIdProvider(programIdObj));

    if (initialProgram != null) {
      state = ProgramEditorState(profileId: profileId, program: initialProgram);
    }
  }

  /// Сохранение изменений в репозиторий.
  Future<void> saveChanges() async {
    final program = state.program;
    final profileId = state.profileId;

    if (program == null || profileId == null) return;

    final result = await ref
        .read(saveProgramUseCaseProvider)
        .call(SaveProgramParams(profileId: profileId, program: program));

    result.fold((_) {
      state = state.copyWith(hasChanges: false);
      ref.invalidate(flightProgramsProvider(profileId));
    }, (failure) => null);
  }

  void addStep(FlightProgramStep step) {
    if (state.program == null) return;
    state = state.copyWith(
      program: state.program!.addStep(step),
      hasChanges: true,
    );
  }

  void updateStep(int index, FlightProgramStep step) {
    if (state.program == null) return;
    state = state.copyWith(
      program: state.program!.updateStep(index, step),
      hasChanges: true,
    );
  }

  void deleteStep(int index) {
    if (state.program == null) return;
    state = state.copyWith(
      program: state.program!.removeStep(index),
      hasChanges: true,
    );
  }
}
