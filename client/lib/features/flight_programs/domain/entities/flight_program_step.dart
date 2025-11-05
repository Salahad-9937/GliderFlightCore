import 'dart:convert';

/// Сущность, представляющая один шаг в полетной программе.
class FlightProgramStep {
  /// Время от старта в секундах, когда должен сработать этот шаг.
  final int time;

  /// Направление вращения сервопривода (1: по часовой, -1: против часовой).
  final int direction;

  /// Длительность вращения сервопривода в миллисекундах.
  final int duration;

  FlightProgramStep({
    required this.time,
    required this.direction,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'time': time,
      'direction': direction,
      'duration': duration,
    };
  }

  factory FlightProgramStep.fromMap(Map<String, dynamic> map) {
    return FlightProgramStep(
      time: map['time']?.toInt() ?? 0,
      direction: map['direction']?.toInt() ?? 0,
      duration: map['duration']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory FlightProgramStep.fromJson(String source) =>
      FlightProgramStep.fromMap(json.decode(source));
}