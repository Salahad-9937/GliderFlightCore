import 'dart:convert';

/// Сущность, представляющая один последовательный шаг в полетной программе.
class FlightProgramStep {
  /// Целевой угол поворота сервопривода в градусах (обычно 0-180).
  final int angle;

  /// Секунды задержки перед выполнением поворота.
  final int delaySec;

  /// Миллисекунды задержки перед выполнением поворота.
  final int delayMs;

  FlightProgramStep({required this.angle, this.delaySec = 0, this.delayMs = 0});

  /// Возвращает общую задержку в миллисекундах.
  int get totalDelayMs => delaySec * 1000 + delayMs;

  /// Преобразует объект в Map для JSON.
  Map<String, dynamic> toMap() {
    return {'angle': angle, 'delaySec': delaySec, 'delayMs': delayMs};
  }

  /// Создает объект из Map.
  factory FlightProgramStep.fromMap(Map<String, dynamic> map) {
    return FlightProgramStep(
      angle: map['angle']?.toInt() ?? 0,
      delaySec: map['delaySec']?.toInt() ?? 0,
      delayMs: map['delayMs']?.toInt() ?? 0,
    );
  }

  /// Сериализация в строку JSON.
  String toJson() => json.encode(toMap());

  /// Десериализация из строки JSON.
  factory FlightProgramStep.fromJson(String source) =>
      FlightProgramStep.fromMap(json.decode(source));
}
