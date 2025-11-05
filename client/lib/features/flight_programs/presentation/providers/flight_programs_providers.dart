import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/repositories/flight_program_repository_impl.dart';
import '../../domain/entities/flight_program.dart';
import '../../domain/repositories/flight_program_repository.dart';

// --- ШАГ 1: ПРОВАЙДЕР ДЛЯ ЧТЕНИЯ ДАННЫХ ---

/// Этот провайдер отвечает ТОЛЬКО за загрузку и отображение списка программ.
/// `FutureProvider.family` - это простая и надежная конструкция для этого.
final flightProgramsProvider =
    FutureProvider.family<List<FlightProgram>, String>((ref, profileId) {
  // Получаем репозиторий
  final repository = ref.watch(flightProgramRepositoryProvider);
  // Возвращаем Future, который загружает программы
  return repository.getPrograms(profileId);
});


// --- ШАГ 2: NOTIFIER ДЛЯ ИЗМЕНЕНИЯ ДАННЫХ ---

/// Это обычный класс, а не Riverpod Notifier. Он содержит бизнес-логику.
class FlightProgramsController {
  final Ref ref;
  FlightProgramsController(this.ref);

  FlightProgramRepository get _repository => ref.read(flightProgramRepositoryProvider);

  /// Добавляет новую программу
  Future<void> addProgram(String profileId, String name) async {
    final newProgram = FlightProgram(id: const Uuid().v4(), name: name);
    await _repository.saveProgram(profileId, newProgram);
    // Инвалидируем `FutureProvider`, чтобы он перезагрузил данные и UI обновился.
    // Это ключевой момент для связи между изменением и чтением.
    ref.invalidate(flightProgramsProvider(profileId));
  }

  /// Удаляет программу
  Future<void> deleteProgram(String profileId, String programId) async {
    await _repository.deleteProgram(profileId, programId);
    ref.invalidate(flightProgramsProvider(profileId));
  }
}

// --- ШАГ 3: ПРОВАЙДЕР ДЛЯ ДОСТУПА К КОНТРОЛЛЕРУ ---

/// Простой `Provider`, который создает экземпляр нашего контроллера.
/// Мы будем использовать его для вызова методов `addProgram`, `deleteProgram`.
final flightProgramsControllerProvider = Provider<FlightProgramsController>((ref) {
  return FlightProgramsController(ref);
});