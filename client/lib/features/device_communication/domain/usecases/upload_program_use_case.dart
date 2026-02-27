import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../../../flight_programs/domain/entities/flight_program.dart';
import '../repositories/device_repository.dart';

class UploadProgramUseCase implements UseCase<void, FlightProgram> {
  final IDeviceRepository _repository;
  UploadProgramUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(FlightProgram program) {
    return _repository.uploadProgram(program);
  }
}
