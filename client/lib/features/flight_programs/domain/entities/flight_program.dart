import 'flight_program_step.dart';

/// Сущность полетной программы.
class FlightProgram {
  final String id;
  final String name;
  final List<FlightProgramStep> steps;

  const FlightProgram({
    required this.id,
    required this.name,
    this.steps = const [],
  });

  /// Общая длительность программы в миллисекундах.
  int get totalDurationMs =>
      steps.fold(0, (sum, step) => sum + step.totalDelayMs);

  /// Общая длительность в секундах (для UI).
  double get totalDurationSec => totalDurationMs / 1000.0;

  /// Создает копию программы с обновленным списком шагов.
  FlightProgram copyWithSteps(List<FlightProgramStep> newSteps) {
    return FlightProgram(
      id: id,
      name: name,
      steps: List.unmodifiable(newSteps),
    );
  }

  /// Добавление шага.
  FlightProgram addStep(FlightProgramStep step) {
    return copyWithSteps([...steps, step]);
  }

  /// Удаление шага.
  FlightProgram removeStep(int index) {
    final newSteps = List<FlightProgramStep>.from(steps)..removeAt(index);
    return copyWithSteps(newSteps);
  }

  /// Обновление шага.
  FlightProgram updateStep(int index, FlightProgramStep step) {
    final newSteps = List<FlightProgramStep>.from(steps);
    newSteps[index] = step;
    return copyWithSteps(newSteps);
  }
}
