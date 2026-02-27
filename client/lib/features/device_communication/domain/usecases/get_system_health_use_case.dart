import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/system_health.dart';
import '../repositories/device_repository.dart';

class GetSystemHealthUseCase implements UseCase<SystemHealth, NoParams> {
  final IDeviceRepository _repository;
  GetSystemHealthUseCase(this._repository);

  @override
  Future<Result<SystemHealth, Failure>> call(NoParams params) {
    return _repository.getSystemHealth();
  }
}
