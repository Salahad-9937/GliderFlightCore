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

  void init(String profileId, String programId) {
    if (state.program != null && state.program!.id == programId) return;

    final programIdObj = ProgramId(profileId: profileId, programId: programId);
    final initialProgram = ref.read(programByIdProvider(programIdObj));

    if (initialProgram != null) {
      state = ProgramEditorState(
        profileId: profileId,
        program: initialProgram, // Используем иммутабельную сущность
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

final programEditorProvider =
    NotifierProvider<ProgramEditorNotifier, ProgramEditorState>(
      ProgramEditorNotifier.new,
    );
