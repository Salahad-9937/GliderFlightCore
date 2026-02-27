/// DTO для шага программы.
class FlightProgramStepDto {
  final int angle;
  final int delaySec;
  final int delayMs;

  const FlightProgramStepDto({
    required this.angle,
    required this.delaySec,
    required this.delayMs,
  });

  factory FlightProgramStepDto.fromJson(Map<String, dynamic> json) {
    return FlightProgramStepDto(
      angle: json['angle']?.toInt() ?? 0,
      delaySec: json['delaySec']?.toInt() ?? 0,
      delayMs: json['delayMs']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'angle': angle,
    'delaySec': delaySec,
    'delayMs': delayMs,
  };
}

/// DTO для всей программы.
class FlightProgramDto {
  final String id;
  final String name;
  final List<FlightProgramStepDto> steps;

  const FlightProgramDto({
    required this.id,
    required this.name,
    required this.steps,
  });

  factory FlightProgramDto.fromJson(Map<String, dynamic> json) {
    return FlightProgramDto(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      steps: (json['steps'] as List? ?? [])
          .map((e) => FlightProgramStepDto.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'steps': steps.map((e) => e.toJson()).toList(),
  };
}
