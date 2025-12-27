import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/flight_programs/domain/entities/flight_program.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';
import 'device_connection_providers.dart';

/// Контроллер, отвечающий за процесс загрузки программы на устройство.
///
/// Ответственность:
/// - Оркестрация процесса загрузки.
/// - Взаимодействие с DeviceConnectionNotifier для управления поллингом.
class ProgramUploadController {
  final Ref ref;

  ProgramUploadController(this.ref);

  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);

  /// Загружает полетную программу на устройство.
  /// Возвращает true, если успешно.
  Future<bool> uploadProgram(FlightProgram program) async {
    final deviceState = ref.read(deviceConnectionNotifierProvider);
    final connectionNotifier = ref.read(deviceConnectionNotifierProvider.notifier);

    // 1. Проверка предварительных условий
    if (deviceState.status != DeviceStatus.connected || deviceState.ipAddress == null) {
      return false;
    }

    // 2. Приостановка опроса статуса, чтобы не забивать канал
    connectionNotifier.pausePolling();

    try {
      // 3. Выполнение загрузки
      final success = await _repository.uploadProgram(deviceState.ipAddress!, program);
      return success;
    } finally {
      // 4. Возобновление опроса в любом случае (успех или ошибка)
      connectionNotifier.resumePolling();
    }
  }
}

/// Провайдер для контроллера загрузки.
final programUploadControllerProvider = Provider<ProgramUploadController>((ref) {
  return ProgramUploadController(ref);
});