import '../../domain/entities/flight_program.dart';
import '../../domain/entities/flight_program_step.dart';
import '../../domain/value_objects/servo_angle.dart';
import '../../domain/value_objects/step_duration.dart';
import '../models/flight_program_dto.dart';

class FlightProgramMapper {
  static FlightProgram toEntity(FlightProgramDto dto) {
    return FlightProgram(
      id: dto.id,
      name: dto.name,
      steps: dto.steps
          .map(
            (s) => FlightProgramStep(
              angle: ServoAngle(s.angle),
              duration: StepDuration(s.delaySec * 1000 + s.delayMs),
            ),
          )
          .toList(),
    );
  }

  static FlightProgramDto fromEntity(FlightProgram entity) {
    return FlightProgramDto(
      id: entity.id,
      name: entity.name,
      steps: entity.steps
          .map(
            (s) => FlightProgramStepDto(
              angle: s.angle.value,
              delaySec: s.duration.totalMs ~/ 1000,
              delayMs: s.duration.totalMs % 1000,
            ),
          )
          .toList(),
    );
  }
}
