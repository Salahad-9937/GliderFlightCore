/// Контейнер для всех локализованных строк приложения.
class AppStrings {
  // --- Общие ---
  final String appTitle;
  final String error;
  final String cancel;
  final String save;
  final String retry;
  final String ok;
  final String delete;
  final String confirmation;

  // --- Подключение ---
  final String connectionTitle;
  final String connectionStep1;
  final String connectionStep2;
  final String connectionCheck;
  final String connectionSearching;
  final String connectionError;
  final String connectionLost;
  final String disconnect;

  // --- Телеметрия ---
  final String sensorsActive;
  final String telemetryTitle;
  final String temperature;
  final String pressure;
  final String power;
  final String altitudeUnit;
  final String sensorError;
  final String calibratingProgress;

  // --- Диагностика системы ---
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

  // --- Калибровка ---
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

  // --- Панель управления ---
  final String profileNotFound;
  final String flightHistory;
  final String sync;
  final String noFlightData;
  final String renameGlider;

  // --- Полетные программы ---
  final String programsTitle;
  final String createProgram;
  final String editProgram;
  final String newProgram;
  final String programName;
  final String nameEmptyError;
  final String noPrograms;
  final String addFirstProgram;
  final String uploadToDevice;
  final String edit;
  final String deleteProgramConfirm;
  final String programDeleted;
  final String uploadSuccess;
  final String uploadError;
  final String connectFirst;
  final String saveLocalSuccess;
  final String unsavedChangesTitle;
  final String unsavedChangesDesc;
  final String exit;

  // --- Редактор шагов ---
  final String stepNumber;
  final String angle;
  final String angleLabel;
  final String angleHelper;
  final String angleError;
  final String delayBefore;
  final String seconds;
  final String milliseconds;
  final String msMaxError;
  final String delayDesc;
  final String noSteps;
  final String addFirstStep;

  const AppStrings({
    required this.appTitle,
    required this.error,
    required this.cancel,
    required this.save,
    required this.retry,
    required this.ok,
    required this.delete,
    required this.confirmation,
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
    required this.profileNotFound,
    required this.flightHistory,
    required this.sync,
    required this.noFlightData,
    required this.renameGlider,
    required this.programsTitle,
    required this.createProgram,
    required this.editProgram,
    required this.newProgram,
    required this.programName,
    required this.nameEmptyError,
    required this.noPrograms,
    required this.addFirstProgram,
    required this.uploadToDevice,
    required this.edit,
    required this.deleteProgramConfirm,
    required this.programDeleted,
    required this.uploadSuccess,
    required this.uploadError,
    required this.connectFirst,
    required this.saveLocalSuccess,
    required this.unsavedChangesTitle,
    required this.unsavedChangesDesc,
    required this.exit,
    required this.stepNumber,
    required this.angle,
    required this.angleLabel,
    required this.angleHelper,
    required this.angleError,
    required this.delayBefore,
    required this.seconds,
    required this.milliseconds,
    required this.msMaxError,
    required this.delayDesc,
    required this.noSteps,
    required this.addFirstStep,
  });

  static const ru = AppStrings(
    appTitle: 'Glider Flight Core',
    error: 'Ошибка',
    cancel: 'Отмена',
    save: 'Сохранить',
    retry: 'Попробовать снова',
    ok: 'ОК',
    delete: 'Удалить',
    confirmation: 'Подтверждение',
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
    profileNotFound: 'Профиль не найден',
    flightHistory: 'История полетов',
    sync: 'Синхронизировать',
    noFlightData: 'Нет данных о полетах',
    renameGlider: 'Переименовать планер',
    programsTitle: 'Полетные программы',
    createProgram: 'Создать программу',
    editProgram: 'Редактировать программу',
    newProgram: 'Новая программа полета',
    programName: 'Название программы',
    nameEmptyError: 'Название не может быть пустым',
    noPrograms: 'Нет созданных программ',
    addFirstProgram: 'Нажмите "+", чтобы добавить',
    uploadToDevice: 'Загрузить на планер',
    edit: 'Редактировать',
    deleteProgramConfirm: 'Вы уверены, что хотите удалить программу',
    programDeleted: 'Программа удалена',
    uploadSuccess: 'Программа успешно загружена',
    uploadError: 'Ошибка загрузки программы',
    connectFirst: 'Сначала подключитесь к планеру',
    saveLocalSuccess: 'Программа сохранена локально',
    unsavedChangesTitle: 'Несохраненные изменения',
    unsavedChangesDesc:
        'Вы уверены, что хотите выйти? Изменения будут потеряны.',
    exit: 'Выйти',
    stepNumber: 'Шаг',
    angle: 'Угол',
    angleLabel: 'Угол (градусы)',
    angleHelper: 'Обычно от 0 до 180',
    angleError: 'Введите угол от 0 до 180',
    delayBefore: 'Задержка перед поворотом',
    seconds: 'Секунды',
    milliseconds: 'Миллисекунды',
    msMaxError: 'Макс. 999',
    delayDesc: 'Время отсчитывается от завершения предыдущего шага.',
    noSteps: 'Нет добавленных шагов',
    addFirstStep: 'Нажмите "+", чтобы добавить первый шаг',
  );
}
