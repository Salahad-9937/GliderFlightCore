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
}
