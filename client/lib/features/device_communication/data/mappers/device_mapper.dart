import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/entities/system_health.dart';
import '../models/device_status_dto.dart';
import '../models/system_health_dto.dart';

/// Маппер для преобразования DTO в доменные сущности.
class DeviceMapper {
  /// Преобразует DTO статуса в сущность Device.
  static Device toEntity(DeviceStatusDto dto, {required String ipAddress}) {
    return Device(
      status: DeviceStatus.connected,
      ipAddress: ipAddress,
      isHardwareOk: dto.hwOk,
      isCalibrated: dto.calibrated,
      isCalibrating: dto.calibrating,
      isMonitoring: dto.monitoring,
      isLogging: dto.logging,
      isStable: dto.stable,
      storedBasePressure: dto.storedBase,
      currentPressure: dto.currentP,
      basePressure: dto.base,
      altitude: dto.alt,
      temperature: dto.temp,
      vcc: dto.vcc,
      calibrationPhase: dto.calibPhase,
      calibrationProgress: dto.calibProgress,
    );
  }

  /// Преобразует DTO диагностики в сущность SystemHealth.
  static SystemHealth toSystemHealthEntity(SystemHealthDto dto) {
    return SystemHealth(
      uptime: dto.uptime,
      freeHeap: dto.freeHeap,
      fsTotal: dto.fsTotal,
      fsUsed: dto.fsUsed,
      chipId: dto.chipId,
      version: dto.version,
      timestamp: DateTime.now(),
    );
  }
}
