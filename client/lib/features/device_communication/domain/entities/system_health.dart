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
}
