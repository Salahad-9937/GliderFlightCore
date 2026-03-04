import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/usecases/cancel_operation_use_case.dart';
import '../../domain/usecases/get_device_status_use_case.dart';
import '../../domain/usecases/get_system_health_use_case.dart';
import '../../domain/usecases/save_calibration_use_case.dart';
import '../../domain/usecases/start_calibration_use_case.dart';
import '../../domain/usecases/toggle_monitoring_use_case.dart';
import '../../domain/usecases/upload_program_use_case.dart';
import '../../domain/usecases/zero_altitude_use_case.dart';

part 'device_usecase_providers.g.dart';

@riverpod
GetDeviceStatusUseCase getDeviceStatusUseCase(Ref ref) {
  return GetDeviceStatusUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
GetSystemHealthUseCase getSystemHealthUseCase(Ref ref) {
  return GetSystemHealthUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
UploadProgramUseCase uploadProgramUseCase(Ref ref) {
  return UploadProgramUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
ZeroAltitudeUseCase zeroAltitudeUseCase(Ref ref) {
  return ZeroAltitudeUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
StartCalibrationUseCase startCalibrationUseCase(Ref ref) {
  return StartCalibrationUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
CancelOperationUseCase cancelOperationUseCase(Ref ref) {
  return CancelOperationUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
SaveCalibrationUseCase saveCalibrationUseCase(Ref ref) {
  return SaveCalibrationUseCase(ref.watch(deviceRepositoryProvider));
}

@riverpod
ToggleMonitoringUseCase toggleMonitoringUseCase(Ref ref) {
  return ToggleMonitoringUseCase(ref.watch(deviceRepositoryProvider));
}
