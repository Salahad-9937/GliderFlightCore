import 'device_status.dart';

/// Сущность, представляющая бортовое устройство и его телеметрию.
class Device {
  final DeviceStatus status;
  final String? ipAddress;
  final String? errorMessage;

  final bool isHardwareOk;
  final bool isCalibrating;
  final bool isCalibrated;
  final bool isMonitoring;
  final bool isLogging;
  final bool isStable;

  final double? altitude;
  final double? temperature;
  final double? currentPressure;
  final double? basePressure;
  final double? storedBasePressure;
  final double? vcc;

  final String? calibrationPhase;
  final int? calibrationProgress;

  const Device({
    required this.status,
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

  bool get isVccCritical => vcc != null && vcc! < 3.3;

  /// Геттеры для форматированного вывода (вынос из UI)
  String get formattedAltitude => altitude?.toStringAsFixed(1) ?? '0.0';
  String get formattedTemperature => temperature?.toStringAsFixed(1) ?? '--';
  String get formattedPressure => currentPressure?.toStringAsFixed(0) ?? '--';
  String get formattedVcc => vcc?.toStringAsFixed(2) ?? '--';

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
