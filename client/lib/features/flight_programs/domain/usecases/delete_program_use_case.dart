import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../repositories/flight_program_repository.dart';

/// Параметры для удаления программы.
class DeleteProgramParams {
  final String profileId;
  final String programId;

  const DeleteProgramParams({required this.profileId, required this.programId});
}

/// Сценарий удаления программы.
class DeleteProgramUseCase implements UseCase<void, DeleteProgramParams> {
  final IFlightProgramRepository _repository;

  DeleteProgramUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(DeleteProgramParams params) {
    return _repository.deleteProgram(params.profileId, params.programId);
  }
}
