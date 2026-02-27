import '../../domain/entities/flight_program.dart';
import '../../domain/entities/flight_program_step.dart';
import '../models/flight_program_dto.dart';

class FlightProgramMapper {
  static FlightProgram toEntity(FlightProgramDto dto) {
    return FlightProgram(
      id: dto.id,
      name: dto.name,
      steps: dto.steps
          .map(
            (s) => FlightProgramStep(
              angle: s.angle,
              delaySec: s.delaySec,
              delayMs: s.delayMs,
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
              angle: s.angle,
              delaySec: s.delaySec,
              delayMs: s.delayMs,
            ),
          )
          .toList(),
    );
  }
}
