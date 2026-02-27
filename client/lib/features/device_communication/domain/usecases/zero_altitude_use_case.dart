import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/device_repository.dart';

class ZeroAltitudeUseCase implements UseCase<void, NoParams> {
  final IDeviceRepository _repository;
  ZeroAltitudeUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(NoParams params) {
    return _repository.zeroAltitude();
  }
}
