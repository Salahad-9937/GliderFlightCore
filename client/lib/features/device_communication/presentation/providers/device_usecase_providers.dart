import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/usecases/cancel_operation_use_case.dart';
import '../../domain/usecases/get_device_status_use_case.dart';
import '../../domain/usecases/get_system_health_use_case.dart';
import '../../domain/usecases/save_calibration_use_case.dart';
import '../../domain/usecases/start_calibration_use_case.dart';
import '../../domain/usecases/toggle_monitoring_use_case.dart';
import '../../domain/usecases/upload_program_use_case.dart';
import '../../domain/usecases/zero_altitude_use_case.dart';

final getDeviceStatusUseCaseProvider = Provider((ref) {
  return GetDeviceStatusUseCase(ref.watch(deviceRepositoryProvider));
});

final getSystemHealthUseCaseProvider = Provider((ref) {
  return GetSystemHealthUseCase(ref.watch(deviceRepositoryProvider));
});

final uploadProgramUseCaseProvider = Provider((ref) {
  return UploadProgramUseCase(ref.watch(deviceRepositoryProvider));
});

final zeroAltitudeUseCaseProvider = Provider((ref) {
  return ZeroAltitudeUseCase(ref.watch(deviceRepositoryProvider));
});

final startCalibrationUseCaseProvider = Provider((ref) {
  return StartCalibrationUseCase(ref.watch(deviceRepositoryProvider));
});

final cancelOperationUseCaseProvider = Provider((ref) {
  return CancelOperationUseCase(ref.watch(deviceRepositoryProvider));
});

final saveCalibrationUseCaseProvider = Provider((ref) {
  return SaveCalibrationUseCase(ref.watch(deviceRepositoryProvider));
});

final toggleMonitoringUseCaseProvider = Provider((ref) {
  return ToggleMonitoringUseCase(ref.watch(deviceRepositoryProvider));
});
