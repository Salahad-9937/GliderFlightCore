import '../value_objects/servo_angle.dart';
import '../value_objects/step_duration.dart';

/// Сущность шага полетной программы.
///
/// Использует Value Objects для обеспечения бизнес-валидации.
class FlightProgramStep {
  final ServoAngle angle;
  final StepDuration duration;

  const FlightProgramStep({required this.angle, required this.duration});

  /// Геттеры-прокси для UI и мапперов.
  int get angleValue => angle.value;
  int get totalDelayMs => duration.totalMs;
  int get delaySec => duration.totalMs ~/ 1000;
  int get delayMs => duration.totalMs % 1000;

  FlightProgramStep copyWith({ServoAngle? angle, StepDuration? duration}) {
    return FlightProgramStep(
      angle: angle ?? this.angle,
      duration: duration ?? this.duration,
    );
  }
}
