import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../entities/flight_program.dart';

/// Интерфейс репозитория для управления полетными программами.
abstract interface class IFlightProgramRepository {
  /// Возвращает список программ для указанного профиля планера.
  Future<Result<List<FlightProgram>, Failure>> getPrograms(String profileId);

  /// Сохраняет или обновляет программу для указанного профиля.
  Future<Result<void, Failure>> saveProgram(
    String profileId,
    FlightProgram program,
  );

  /// Удаляет программу по ID для указанного профиля.
  Future<Result<void, Failure>> deleteProgram(
    String profileId,
    String programId,
  );
}
