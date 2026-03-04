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

  int get totalDurationMs =>
      steps.fold(0, (sum, step) => sum + step.totalDelayMs);

  double get totalDurationSec => totalDurationMs / 1000.0;

  /// Геттер для форматированной длительности (вынос из UI).
  String get formattedTotalDuration => totalDurationSec.toStringAsFixed(2);

  FlightProgram copyWithSteps(List<FlightProgramStep> newSteps) {
    return FlightProgram(
      id: id,
      name: name,
      steps: List.unmodifiable(newSteps),
    );
  }

  FlightProgram addStep(FlightProgramStep step) {
    return copyWithSteps([...steps, step]);
  }

  FlightProgram removeStep(int index) {
    final newSteps = List<FlightProgramStep>.from(steps)..removeAt(index);
    return copyWithSteps(newSteps);
  }

  FlightProgram updateStep(int index, FlightProgramStep step) {
    final newSteps = List<FlightProgramStep>.from(steps);
    newSteps[index] = step;
    return copyWithSteps(newSteps);
  }
}
