import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/repositories/device_repository_impl.dart';
import 'device_connection_providers.dart';

/// Контроллер для управления настройками датчиков (включение/выключение).
class SensorSettingsController {
  final Ref ref;

  SensorSettingsController(this.ref);

  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);

  /// Переключает режим мониторинга датчиков.
  Future<bool> toggleMonitoring(bool enable) async {
    final device = ref.read(deviceConnectionNotifierProvider);
    final connectionNotifier = ref.read(deviceConnectionNotifierProvider.notifier);
    
    if (device.status != DeviceStatus.connected || device.ipAddress == null) {
      return false;
    }

    // 1. Приостанавливаем опрос, чтобы избежать коллизий на ESP8266
    connectionNotifier.pausePolling();

    try {
      // 2. Отправляем команду
      return await _repository.setSensorMonitoring(device.ipAddress!, enable);
    } finally {
      // 3. Возобновляем опрос в любом случае
      connectionNotifier.resumePolling();
    }
  }
}

final sensorSettingsControllerProvider = Provider<SensorSettingsController>((ref) {
  return SensorSettingsController(ref);
});