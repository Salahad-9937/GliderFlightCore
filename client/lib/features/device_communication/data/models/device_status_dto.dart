/// Объект передачи данных статуса устройства.
///
/// Отвечает за парсинг сырого JSON от эндпоинта /status.
class DeviceStatusDto {
  final bool hwOk;
  final bool calibrated;
  final bool calibrating;
  final bool monitoring;
  final bool logging;
  final double? storedBase;
  final double? currentP;
  final double? base;
  final double? alt;
  final double? temp;
  final double? vcc;
  final bool stable;
  final String calibPhase;
  final int calibProgress;

  const DeviceStatusDto({
    required this.hwOk,
    required this.calibrated,
    required this.calibrating,
    required this.monitoring,
    required this.logging,
    this.storedBase,
    this.currentP,
    this.base,
    this.alt,
    this.temp,
    this.vcc,
    required this.stable,
    required this.calibPhase,
    required this.calibProgress,
  });

  factory DeviceStatusDto.fromJson(Map<String, dynamic> json) {
    return DeviceStatusDto(
      hwOk: json['hw_ok'] ?? false,
      calibrated: json['calibrated'] ?? false,
      calibrating: json['calibrating'] ?? false,
      monitoring: json['monitoring'] ?? false,
      logging: json['logging'] ?? false,
      storedBase: (json['stored_base'] as num?)?.toDouble(),
      currentP: (json['current_p'] as num?)?.toDouble(),
      base: (json['base'] as num?)?.toDouble(),
      alt: (json['alt'] as num?)?.toDouble(),
      temp: (json['temp'] as num?)?.toDouble(),
      vcc: (json['vcc'] as num?)?.toDouble(),
      stable: json['stable'] ?? false,
      calibPhase: json['calib_phase'] ?? 'idle',
      calibProgress: (json['calib_progress'] as num?)?.toInt() ?? 0,
    );
  }
}
