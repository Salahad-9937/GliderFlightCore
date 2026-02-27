import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_usecase_providers.dart';

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

final sensorSettingsControllerProvider = Provider<SensorSettingsController>((
  ref,
) {
  return SensorSettingsController(ref);
});
