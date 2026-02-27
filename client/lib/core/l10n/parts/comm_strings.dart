/// Строки фичи device_communication (подключение, телеметрия, калибровка).
class CommStrings {
  final String connectionTitle;
  final String connectionStep1;
  final String connectionStep2;
  final String connectionCheck;
  final String connectionSearching;
  final String connectionError;
  final String connectionLost;
  final String disconnect;
  final String sensorsActive;
  final String telemetryTitle;
  final String temperature;
  final String pressure;
  final String power;
  final String altitudeUnit;
  final String sensorError;
  final String calibratingProgress;
  final String calibrationTitle;
  final String operationalControl;
  final String zeroAltitudeBtn;
  final String zeroingProcess;
  final String fullSetup;
  final String startFullCalibBtn;
  final String stabilizationProcess;
  final String measuringProcess;
  final String calibSuccess;
  final String saveToMemoryBtn;
  final String calibSavedNotify;
  final String cancelOperation;

  const CommStrings({
    required this.connectionTitle,
    required this.connectionStep1,
    required this.connectionStep2,
    required this.connectionCheck,
    required this.connectionSearching,
    required this.connectionError,
    required this.connectionLost,
    required this.disconnect,
    required this.sensorsActive,
    required this.telemetryTitle,
    required this.temperature,
    required this.pressure,
    required this.power,
    required this.altitudeUnit,
    required this.sensorError,
    required this.calibratingProgress,
    required this.calibrationTitle,
    required this.operationalControl,
    required this.zeroAltitudeBtn,
    required this.zeroingProcess,
    required this.fullSetup,
    required this.startFullCalibBtn,
    required this.stabilizationProcess,
    required this.measuringProcess,
    required this.calibSuccess,
    required this.saveToMemoryBtn,
    required this.calibSavedNotify,
    required this.cancelOperation,
  });

  static const ru = CommStrings(
    connectionTitle: 'Подключение',
    connectionStep1: '1. Включите питание планера.',
    connectionStep2: '2. Подключите телефон к Wi-Fi сети "Glider-Timer".',
    connectionCheck: 'Проверить подключение',
    connectionSearching: 'Поиск устройства...',
    connectionError: 'Не удалось подключиться',
    connectionLost: 'Связь потеряна',
    disconnect: 'Отключиться',
    sensorsActive: 'Датчики активны',
    telemetryTitle: 'Телеметрия',
    temperature: 'Температура',
    pressure: 'Давление',
    power: 'Питание',
    altitudeUnit: 'м',
    sensorError: 'Ошибка датчика BMP180! Проверьте соединение на плате.',
    calibratingProgress: 'Идет калибровка...',
    calibrationTitle: 'Калибровка датчиков',
    operationalControl: 'Оперативное управление',
    zeroAltitudeBtn: 'Обнулить высоту (Zero)',
    zeroingProcess: 'Обнуление высоты...',
    fullSetup: 'Полная настройка',
    startFullCalibBtn: 'Запустить полную калибровку',
    stabilizationProcess: 'Термостабилизация...',
    measuringProcess: 'Сбор данных и усреднение...',
    calibSuccess: 'Калибровка завершена!',
    saveToMemoryBtn: 'Сохранить в память',
    calibSavedNotify: 'Калибровка сохранена в память',
    cancelOperation: 'Отменить операцию',
  );
}
