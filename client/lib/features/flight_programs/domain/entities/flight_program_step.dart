/// Сущность шага полетной программы.
///
/// Чистая модель: только данные и базовая логика расчета.
class FlightProgramStep {
  final int angle;
  final int delaySec;
  final int delayMs;

  const FlightProgramStep({
    required this.angle,
    this.delaySec = 0,
    this.delayMs = 0,
  });

  int get totalDelayMs => delaySec * 1000 + delayMs;
}
