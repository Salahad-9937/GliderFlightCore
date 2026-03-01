/// Строки фичи flight_programs (редактор, список программ).
class ProgStrings {
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

  // Новые строки для тактического UI
  final String missionSequenceEditor;
  final String totalMissionTime;
  final String sequenceStatus;
  final String modified;
  final String synced;
  final String unsavedData;
  final String abortEditing;
  final String stepConfig;
  final String servoAngle;
  final String confirm;
  final String newMissionProgram;
  final String eraseProgram;
  final String confirmErase;
  final String noMissionSteps;
  final String unitDeg;
  final String unitSecShort;
  final String missionDataSaved;

  const ProgStrings({
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
    required this.missionSequenceEditor,
    required this.totalMissionTime,
    required this.sequenceStatus,
    required this.modified,
    required this.synced,
    required this.unsavedData,
    required this.abortEditing,
    required this.stepConfig,
    required this.servoAngle,
    required this.confirm,
    required this.newMissionProgram,
    required this.eraseProgram,
    required this.confirmErase,
    required this.noMissionSteps,
    required this.unitDeg,
    required this.unitSecShort,
    required this.missionDataSaved,
  });

  static const ru = ProgStrings(
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
    missionSequenceEditor: 'РЕДАКТОР ПОЛЕТНОЙ ПОСЛЕДОВАТЕЛЬНОСТИ',
    totalMissionTime: 'ОБЩЕЕ ВРЕМЯ МИССИИ',
    sequenceStatus: 'СТАТУС ЦИКЛА',
    modified: 'ИЗМЕНЕНО*',
    synced: 'СИНХРОНИЗИРОВАНО',
    unsavedData: 'НЕСОХРАНЕННЫЕ ДАННЫЕ',
    abortEditing: 'ПРЕРВАТЬ РЕДАКТИРОВАНИЕ И СБРОСИТЬ ИЗМЕНЕНИЯ?',
    stepConfig: 'КОНФИГУРАЦИЯ ШАГА',
    servoAngle: 'УГОЛ СЕРВО (0-180)',
    confirm: 'ПОДТВЕРДИТЬ',
    newMissionProgram: 'НОВАЯ ПОЛЕТНАЯ ПРОГРАММА',
    eraseProgram: 'УДАЛЕНИЕ ПРОГРАММЫ',
    confirmErase: 'ПОДТВЕРДИТЕ УДАЛЕНИЕ МИССИИ:',
    noMissionSteps: 'ШАГИ МИССИИ НЕ ОПРЕДЕЛЕНЫ',
    unitDeg: 'ГРАД',
    unitSecShort: 'СЕК',
    missionDataSaved: 'ДАННЫЕ МИССИИ СОХРАНЕНЫ',
  );
}
