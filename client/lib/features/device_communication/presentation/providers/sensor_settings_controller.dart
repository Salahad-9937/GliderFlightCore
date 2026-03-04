import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'device_usecase_providers.dart';

part 'sensor_settings_controller.g.dart';

/// Контроллер для управления параметрами датчиков.
class SensorSettingsController {
  final Ref _ref;

  SensorSettingsController(this._ref);

  /// Включает или выключает опрос барометра на устройстве.
  Future<bool> toggleMonitoring(bool enable) async {
    final result = await _ref
        .read(toggleMonitoringUseCaseProvider)
        .call(enable);
    return result.fold((_) => true, (_) => false);
  }
}

@riverpod
SensorSettingsController sensorSettingsController(Ref ref) {
  return SensorSettingsController(ref);
}
