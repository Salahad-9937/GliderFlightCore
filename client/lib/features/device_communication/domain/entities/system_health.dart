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

  double get freeHeapKb => freeHeap / 1024.0;
  double get fsUsedKb => fsUsed / 1024.0;
  double get fsTotalKb => fsTotal / 1024.0;

  int get uptimeMinutes => uptime ~/ 60;
  int get uptimeSecondsRemainder => uptime % 60;

  /// Форматированная строка свободной RAM.
  String get freeHeapLabel => '${freeHeapKb.toStringAsFixed(1)} KB';

  /// Форматированная строка состояния файловой системы.
  String get fsMemoryLabel =>
      '${fsUsedKb.toStringAsFixed(0)} / ${fsTotalKb.toStringAsFixed(0)} KB';

  /// Собирает строку аптайма на основе переданных локализованных единиц.
  String formatUptime(String minUnit, String secUnit) {
    if (uptimeMinutes > 0) {
      return '$uptimeMinutes $minUnit $uptimeSecondsRemainder $secUnit';
    }
    return '$uptimeSecondsRemainder $secUnit';
  }
}
