/// Сущность шага полетной программы.
///
/// Содержит бизнес-логику расчета времени и ограничений сервопривода.
class FlightProgramStep {
  /// Угол поворота сервопривода (0-180).
  final int angle;

  /// Задержка в полных секундах.
  final int delaySec;

  /// Задержка в миллисекундах (0-999).
  final int delayMs;

  /// Константы ограничений.
  static const int maxAngle = 180;
  static const int minAngle = 0;
  static const int maxTotalTimeMs = 3600000; // 60 минут

  const FlightProgramStep({
    required this.angle,
    this.delaySec = 0,
    this.delayMs = 0,
  });

  /// Общее время задержки в миллисекундах.
  int get totalDelayMs => (delaySec * 1000) + delayMs;

  /// Создает объект из общего количества миллисекунд.
  factory FlightProgramStep.fromTotalMs(int totalMs, int angle) {
    final clampedMs = totalMs.clamp(0, maxTotalTimeMs);
    return FlightProgramStep(
      angle: angle.clamp(minAngle, maxAngle),
      delaySec: clampedMs ~/ 1000,
      delayMs: clampedMs % 1000,
    );
  }

  /// Расчет минут для UI.
  int get minutes => totalDelayMs ~/ 60000;

  /// Расчет остаточных секунд для UI.
  int get secondsOnly => (totalDelayMs ~/ 1000) % 60;

  /// Расчет остаточных миллисекунд для UI.
  int get millisOnly => totalDelayMs % 1000;

  FlightProgramStep copyWith({int? angle, int? delaySec, int? delayMs}) {
    return FlightProgramStep(
      angle: angle ?? this.angle,
      delaySec: delaySec ?? this.delaySec,
      delayMs: delayMs ?? this.delayMs,
    );
  }
}
