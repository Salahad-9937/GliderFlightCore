import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/architecture/use_case.dart';
import '../entities/flight_program.dart';
import '../repositories/flight_program_repository.dart';

/// Сценарий получения списка программ для профиля.
class GetProgramsUseCase implements UseCase<List<FlightProgram>, String> {
  final IFlightProgramRepository _repository;

  GetProgramsUseCase(this._repository);

  @override
  Future<Result<List<FlightProgram>, Failure>> call(String profileId) {
    return _repository.getPrograms(profileId);
  }
}
