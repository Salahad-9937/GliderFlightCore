/// Объект передачи данных системной диагностики.
///
/// Отвечает за парсинг сырого JSON от эндпоинта /system.
class SystemHealthDto {
  final int uptime;
  final int freeHeap;
  final int fsTotal;
  final int fsUsed;
  final String chipId;
  final String version;

  const SystemHealthDto({
    required this.uptime,
    required this.freeHeap,
    required this.fsTotal,
    required this.fsUsed,
    required this.chipId,
    required this.version,
  });

  factory SystemHealthDto.fromJson(Map<String, dynamic> json) {
    return SystemHealthDto(
      uptime: json['uptime'] ?? 0,
      freeHeap: json['free_heap'] ?? 0,
      fsTotal: json['fs_total'] ?? 0,
      fsUsed: json['fs_used'] ?? 0,
      chipId: json['chip_id'] ?? 'unknown',
      version: json['version'] ?? 'unknown',
    );
  }
}
