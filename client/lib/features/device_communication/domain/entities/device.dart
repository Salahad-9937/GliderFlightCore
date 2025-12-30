import 'device_status.dart';

/// Сущность, представляющая бортовое устройство и его телеметрию.
class Device {
  /// Текущий статус подключения (сетевой слой).
  final DeviceStatus status;

  /// IP-адрес устройства.
  final String? ipAddress;

  /// Сообщение об ошибке.
  final String? errorMessage;

  // --- Флаги состояния устройства (Hardware) ---
  final bool isHardwareOk;
  final bool isCalibrating;
  final bool isCalibrated;
  final bool isMonitoring;
  final bool isLogging;
  final bool isStable;

  // --- Телеметрия ---
  final double? altitude;
  final double? temperature;
  final double? currentPressure; // Текущее давление (live)
  final double? basePressure;    // Базовое давление (активное)
  final double? storedBasePressure; // Сохраненное в памяти давление
  final double? vcc;             // Напряжение питания (Вольты)

  // --- Данные процесса калибровки (Real-time) ---
  final String? calibrationPhase; // "stabilization", "measuring", "zeroing", "idle"
  final int? calibrationProgress; // 0..100

  const Device({
    this.status = DeviceStatus.disconnected,
    this.ipAddress,
    this.errorMessage,
    this.isHardwareOk = false,
    this.isCalibrating = false,
    this.isCalibrated = false,
    this.isMonitoring = false,
    this.isLogging = false,
    this.isStable = false,
    this.altitude,
    this.temperature,
    this.currentPressure,
    this.basePressure,
    this.storedBasePressure,
    this.vcc,
    this.calibrationPhase,
    this.calibrationProgress,
  });

  /// Создает копию объекта с измененными полями.
  Device copyWith({
    DeviceStatus? status,
    String? ipAddress,
    String? errorMessage,
    bool? isHardwareOk,
    bool? isCalibrating,
    bool? isCalibrated,
    bool? isMonitoring,
    bool? isLogging,
    bool? isStable,
    double? altitude,
    double? temperature,
    double? currentPressure,
    double? basePressure,
    double? storedBasePressure,
    double? vcc,
    String? calibrationPhase,
    int? calibrationProgress,
  }) {
    return Device(
      status: status ?? this.status,
      ipAddress: ipAddress ?? this.ipAddress,
      errorMessage: errorMessage ?? this.errorMessage,
      isHardwareOk: isHardwareOk ?? this.isHardwareOk,
      isCalibrating: isCalibrating ?? this.isCalibrating,
      isCalibrated: isCalibrated ?? this.isCalibrated,
      isMonitoring: isMonitoring ?? this.isMonitoring,
      isLogging: isLogging ?? this.isLogging,
      isStable: isStable ?? this.isStable,
      altitude: altitude ?? this.altitude,
      temperature: temperature ?? this.temperature,
      currentPressure: currentPressure ?? this.currentPressure,
      basePressure: basePressure ?? this.basePressure,
      storedBasePressure: storedBasePressure ?? this.storedBasePressure,
      vcc: vcc ?? this.vcc,
      calibrationPhase: calibrationPhase ?? this.calibrationPhase,
      calibrationProgress: calibrationProgress ?? this.calibrationProgress,
    );
  }
}