/// Сущность расширенной диагностики системы.
class SystemHealth {
  final int uptime;
  final int freeHeap;
  final int fsTotal;
  final int fsUsed;
  final String chipId;
  final String version;
  final DateTime timestamp;

  const SystemHealth({
    required this.uptime,
    required this.freeHeap,
    required this.fsTotal,
    required this.fsUsed,
    required this.chipId,
    required this.version,
    required this.timestamp,
  });

  /// Геттеры для выноса логики расчета из UI
  double get freeHeapKb => freeHeap / 1024.0;
  double get fsUsedKb => fsUsed / 1024.0;
  double get fsTotalKb => fsTotal / 1024.0;

  int get uptimeMinutes => uptime ~/ 60;
  int get uptimeSecondsRemainder => uptime % 60;
}
