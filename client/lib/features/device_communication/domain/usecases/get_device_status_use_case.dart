import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/device.dart';
import '../repositories/device_repository.dart';

class GetDeviceStatusUseCase implements UseCase<Device, NoParams> {
  final IDeviceRepository _repository;
  GetDeviceStatusUseCase(this._repository);

  @override
  Future<Result<Device, Failure>> call(NoParams params) {
    return _repository.getDeviceStatus();
  }
}
