import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/domain/contracts/device_payload.dart';
import '../entities/device.dart';
import '../entities/system_health.dart';

/// Абстрактный репозиторий для взаимодействия с бортовым устройством.
abstract interface class IDeviceRepository {
  Future<Result<Device, Failure>> getDeviceStatus();
  Future<Result<SystemHealth, Failure>> getSystemHealth();

  /// Принимает абстрактный [IDevicePayload] вместо конкретной [FlightProgram].
  /// Это разрывает зависимость между фичами.
  Future<Result<void, Failure>> uploadPayload(IDevicePayload payload);

  Future<Result<void, Failure>> zeroAltitude();
  Future<Result<void, Failure>> startCalibration();
  Future<Result<void, Failure>> cancelOperation();
  Future<Result<void, Failure>> saveCalibration();
  Future<Result<void, Failure>> setSensorMonitoring(bool enable);
}
