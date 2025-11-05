import '../entities/flight_program.dart';

/// Абстрактный репозиторий для управления полетными программами.
abstract class FlightProgramRepository {
  /// Возвращает список программ для указанного профиля планера.
  Future<List<FlightProgram>> getPrograms(String profileId);

  /// Сохраняет программу для указанного профиля планера.
  Future<void> saveProgram(String profileId, FlightProgram program);

  /// Удаляет программу у указанного профиля планера.
  Future<void> deleteProgram(String profileId, String programId);
}