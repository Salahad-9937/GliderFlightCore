import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';
import '../../data/repositories/device_repository_impl.dart';
import 'device_connection_providers.dart';

/// Контроллер для отправки команд управления датчиками.
class SensorSettingsController {
  final Ref ref;

  SensorSettingsController(this.ref);

  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);

  Future<bool> toggleMonitoring(bool enable) async {
    final device = ref.read(deviceConnectionNotifierProvider);

    if (device.status != DeviceStatus.connected || device.ipAddress == null) {
      return false;
    }

    try {
      return await _repository.setSensorMonitoring(device.ipAddress!, enable);
    } catch (e) {
      return false;
    }
  }
}

final sensorSettingsControllerProvider = Provider<SensorSettingsController>((
  ref,
) {
  return SensorSettingsController(ref);
});
