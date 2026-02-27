import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/device_repository.dart';

class ToggleMonitoringUseCase implements UseCase<void, bool> {
  final IDeviceRepository _repository;
  ToggleMonitoringUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(bool enable) {
    return _repository.setSensorMonitoring(enable);
  }
}
