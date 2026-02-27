/// Строки фичи control_panel (диагностика, история).
class PanelStrings {
  final String systemDiagTitle;
  final String deviceNotReady;
  final String diagError;
  final String refresh;
  final String firmwareVersion;
  final String uptime;
  final String freeRam;
  final String fsMemory;
  final String chipId;
  final String timeSecAgo;
  final String timeMinAgo;
  final String unitMin;
  final String unitSec;
  final String profileNotFound;
  final String flightHistory;
  final String sync;
  final String noFlightData;
  final String renameGlider;

  const PanelStrings({
    required this.systemDiagTitle,
    required this.deviceNotReady,
    required this.diagError,
    required this.refresh,
    required this.firmwareVersion,
    required this.uptime,
    required this.freeRam,
    required this.fsMemory,
    required this.chipId,
    required this.timeSecAgo,
    required this.timeMinAgo,
    required this.unitMin,
    required this.unitSec,
    required this.profileNotFound,
    required this.flightHistory,
    required this.sync,
    required this.noFlightData,
    required this.renameGlider,
  });

  static const ru = PanelStrings(
    systemDiagTitle: 'Диагностика системы',
    deviceNotReady: 'Устройство не готово',
    diagError: 'Ошибка диагностики',
    refresh: 'Обновить',
    firmwareVersion: 'Версия ПО',
    uptime: 'Uptime',
    freeRam: 'Свободно RAM',
    fsMemory: 'Память FS',
    chipId: 'Chip ID',
    timeSecAgo: 'сек. назад',
    timeMinAgo: 'мин. назад',
    unitMin: 'мин.',
    unitSec: 'сек.',
    profileNotFound: 'Профиль не найден',
    flightHistory: 'История полетов',
    sync: 'Синхронизировать',
    noFlightData: 'Нет данных о полетах',
    renameGlider: 'Переименовать планер',
  );
}
