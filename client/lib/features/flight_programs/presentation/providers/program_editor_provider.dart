import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/flight_program.dart';
import '../../domain/entities/flight_program_step.dart';
import 'flight_programs_providers.dart';
import 'program_id_provider.dart';

/// Состояние редактора полетной программы.
class ProgramEditorState {
  final FlightProgram? program;
  final bool hasChanges;
  final String? profileId;

  const ProgramEditorState({
    this.program,
    this.hasChanges = false,
    this.profileId,
  });

  /// Общая длительность программы в секундах.
  double get totalDurationSec {
    if (program == null) return 0;
    final totalMs = program!.steps.fold(
      0,
      (sum, step) => sum + step.totalDelayMs,
    );
    return totalMs / 1000.0;
  }

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
class ProgramEditorNotifier extends Notifier<ProgramEditorState> {
  @override
  ProgramEditorState build() {
    return const ProgramEditorState();
  }

  /// Инициализация программы. Вызывается из UI при открытии страницы.
  void init(String profileId, String programId) {
    // Избегаем повторной инициализации, если программа уже загружена
    if (state.program != null && state.program!.id == programId) return;

    final programIdObj = ProgramId(profileId: profileId, programId: programId);

    final initialProgram = ref.read(programByIdProvider(programIdObj));

    if (initialProgram != null) {
      state = ProgramEditorState(
        profileId: profileId,
        program: FlightProgram(
          id: initialProgram.id,
          name: initialProgram.name,
          steps: List.from(initialProgram.steps),
        ),
      );
    }
  }

  void saveChanges() {
    if (state.program != null && state.profileId != null) {
      ref
          .read(flightProgramsControllerProvider)
          .updateProgram(state.profileId!, state.program!);
      state = state.copyWith(hasChanges: false);
    }
  }

  void addStep(FlightProgramStep step) {
    if (state.program == null) return;
    final newSteps = List<FlightProgramStep>.from(state.program!.steps)
      ..add(step);
    _updateProgramSteps(newSteps);
  }

  void updateStep(int index, FlightProgramStep step) {
    if (state.program == null) return;
    final newSteps = List<FlightProgramStep>.from(state.program!.steps);
    newSteps[index] = step;
    _updateProgramSteps(newSteps);
  }

  void deleteStep(int index) {
    if (state.program == null) return;
    final newSteps = List<FlightProgramStep>.from(state.program!.steps);
    newSteps.removeAt(index);
    _updateProgramSteps(newSteps);
  }

  void _updateProgramSteps(List<FlightProgramStep> steps) {
    state = state.copyWith(
      program: FlightProgram(
        id: state.program!.id,
        name: state.program!.name,
        steps: steps,
      ),
      hasChanges: true,
    );
  }
}

final programEditorProvider =
    NotifierProvider<ProgramEditorNotifier, ProgramEditorState>(
      ProgramEditorNotifier.new,
    );
