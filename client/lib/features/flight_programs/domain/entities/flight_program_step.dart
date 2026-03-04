import '../value_objects/servo_angle.dart';
import '../value_objects/step_duration.dart';

/// Сущность шага полетной программы.
class FlightProgramStep {
  final ServoAngle angle;
  final StepDuration duration;

  const FlightProgramStep({required this.angle, required this.duration});

  int get totalDelayMs => duration.totalMs;
  int get delaySec => duration.totalMs ~/ 1000;
  int get delayMs => duration.totalMs % 1000;

  /// Геттер для форматированной строки задержки (вынос из UI)
  String get formattedDelay =>
      '$delaySec.${delayMs.toString().padLeft(3, '0')}s';

  FlightProgramStep copyWith({ServoAngle? angle, StepDuration? duration}) {
    return FlightProgramStep(
      angle: angle ?? this.angle,
      duration: duration ?? this.duration,
    );
  }
}
