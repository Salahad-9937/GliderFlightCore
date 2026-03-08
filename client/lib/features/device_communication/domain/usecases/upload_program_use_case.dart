import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../../core/domain/contracts/device_payload.dart';
import '../repositories/device_repository.dart';

/// Сценарий загрузки данных. Работает с интерфейсом [IDevicePayload].
class UploadProgramUseCase implements UseCase<void, IDevicePayload> {
  final IDeviceRepository _repository;
  UploadProgramUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(IDevicePayload payload) {
    return _repository.uploadPayload(payload);
  }
}
