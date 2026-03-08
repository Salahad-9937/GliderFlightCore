import '../../../../core/domain/contracts/device_payload.dart';
import '../../data/mappers/flight_program_mapper.dart';
import 'flight_program_step.dart';

/// Сущность полетной программы.
/// Реализует [IDevicePayload] для загрузки на устройство через абстрактный контракт.
class FlightProgram implements IDevicePayload {
  final String id;
  final String name;
  final List<FlightProgramStep> steps;

  const FlightProgram({
    required this.id,
    required this.name,
    this.steps = const [],
  });

  @override
  Map<String, dynamic> toDeviceJson() {
    // Используем существующий маппер для формирования JSON
    return FlightProgramMapper.fromEntity(this).toJson();
  }

  int get totalDurationMs =>
      steps.fold(0, (sum, step) => sum + step.totalDelayMs);

  double get totalDurationSec => totalDurationMs / 1000.0;

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
