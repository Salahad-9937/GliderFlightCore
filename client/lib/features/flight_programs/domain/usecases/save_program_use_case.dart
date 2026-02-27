import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/flight_program.dart';
import '../repositories/flight_program_repository.dart';

/// Параметры для сохранения программы.
class SaveProgramParams {
  final String profileId;
  final FlightProgram program;

  const SaveProgramParams({required this.profileId, required this.program});
}

/// Сценарий сохранения или обновления программы.
class SaveProgramUseCase implements UseCase<void, SaveProgramParams> {
  final IFlightProgramRepository _repository;

  SaveProgramUseCase(this._repository);

  @override
  Future<Result<void, Failure>> call(SaveProgramParams params) {
    return _repository.saveProgram(params.profileId, params.program);
  }
}
