import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/flight_programs/domain/entities/flight_program.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';
import 'device_connection_providers.dart';

/// Результат попытки загрузки программы.
enum UploadResult {
  success,
  failure,
  notConnected,
}

/// Контроллер, отвечающий за процесс загрузки программы на устройство.
class ProgramUploadController {
  final Ref ref;

  ProgramUploadController(this.ref);

  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);

  /// Загружает полетную программу на устройство.
  /// Возвращает детализированный результат операции.
  Future<UploadResult> uploadProgram(FlightProgram program) async {
    final deviceState = ref.read(deviceConnectionNotifierProvider);
    final connectionNotifier = ref.read(deviceConnectionNotifierProvider.notifier);

    // 1. Проверка подключения (Бизнес-правило: нельзя грузить без связи)
    if (deviceState.status != DeviceStatus.connected || deviceState.ipAddress == null) {
      return UploadResult.notConnected;
    }

    // 2. Приостановка опроса
    connectionNotifier.pausePolling();

    try {
      // 3. Выполнение загрузки
      final success = await _repository.uploadProgram(deviceState.ipAddress!, program);
      return success ? UploadResult.success : UploadResult.failure;
    } catch (e) {
      return UploadResult.failure;
    } finally {
      // 4. Возобновление опроса
      connectionNotifier.resumePolling();
    }
  }
}

/// Провайдер для контроллера загрузки.
final programUploadControllerProvider = Provider<ProgramUploadController>((ref) {
  return ProgramUploadController(ref);
});