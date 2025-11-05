import 'dart:convert';
import 'flight_program_step.dart';

/// Сущность, представляющая полетную программу для конкретного планера.
class FlightProgram {
  /// Уникальный идентификатор программы.
  final String id;

  /// Название программы, например, "Для сильного ветра".
  final String name;

  /// Список шагов, составляющих программу.
  final List<FlightProgramStep> steps;

  FlightProgram({
    required this.id,
    required this.name,
    this.steps = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'steps': steps.map((x) => x.toMap()).toList(),
    };
  }

  factory FlightProgram.fromMap(Map<String, dynamic> map) {
    return FlightProgram(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      steps: List<FlightProgramStep>.from(
          (map['steps'] as List<dynamic>?)?.map((x) => FlightProgramStep.fromMap(x)) ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory FlightProgram.fromJson(String source) =>
      FlightProgram.fromMap(json.decode(source));
}