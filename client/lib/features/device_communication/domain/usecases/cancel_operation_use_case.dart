import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/device_repository.dart';

class CancelOperationUseCase implements UseCase<void, NoParams> {
  final IDeviceRepository _repository;
  CancelOperationUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(NoParams params) {
    return _repository.cancelOperation();
  }
}
