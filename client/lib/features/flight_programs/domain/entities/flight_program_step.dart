import 'dart:convert';

/// Сущность, представляющая один последовательный шаг в полетной программе.
class FlightProgramStep {
  /// Направление вращения сервопривода (1: по часовой, -1: против часовой).
  final int direction;

  /// Секунды вращения сервопривода.
  final int durationSec;

  /// Миллисекунды вращения сервопривода.
  final int durationMs;

  FlightProgramStep({
    required this.direction,
    this.durationSec = 0,
    this.durationMs = 0,
  });

  /// Возвращает общую длительность вращения в миллисекундах.
  int get totalDurationMs => durationSec * 1000 + durationMs;

  Map<String, dynamic> toMap() {
    return {
      'direction': direction,
      'durationSec': durationSec,
      'durationMs': durationMs,
    };
  }

  factory FlightProgramStep.fromMap(Map<String, dynamic> map) {
    return FlightProgramStep(
      direction: map['direction']?.toInt() ?? 1,
      durationSec: map['durationSec']?.toInt() ?? 0,
      durationMs: map['durationMs']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory FlightProgramStep.fromJson(String source) =>
      FlightProgramStep.fromMap(json.decode(source));
}