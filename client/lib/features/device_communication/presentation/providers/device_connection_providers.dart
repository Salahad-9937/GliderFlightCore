import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/architecture/use_case.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import 'device_usecase_providers.dart';
import 'sensor_settings_controller.dart';

/// Нотификатор управления сессией связи с устройством.
class DeviceConnectionNotifier extends Notifier<Device> {
  Timer? _pollingTimer;

  @override
  Device build() {
    ref.onDispose(() => _stopPolling());
    return const Device(status: DeviceStatus.disconnected);
  }

  /// Инициирует подключение к устройству.
  Future<void> connect() async {
    if (state.status == DeviceStatus.connecting) return;

    if (state.status == DeviceStatus.connected) {
      _startPolling();
      await ref.read(sensorSettingsControllerProvider).toggleMonitoring(true);
      return;
    }

    state = state.copyWith(status: DeviceStatus.connecting);

    final result = await ref
        .read(getDeviceStatusUseCaseProvider)
        .call(const NoParams());

    result.fold(
      (device) async {
        state = device;
        await ref.read(sensorSettingsControllerProvider).toggleMonitoring(true);
        _startPolling();
      },
      (failure) {
        state = Device(
          status: DeviceStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Разрывает соединение и останавливает опрос.
  void disconnect() {
    _stopPolling();

    final wasConnected = state.status == DeviceStatus.connected;

    if (wasConnected) {
      ref.read(toggleMonitoringUseCaseProvider).call(false);
    }

    // Используем Timer.run для избежания конфликтов в жизненном цикле Riverpod
    Timer.run(() {
      state = const Device(status: DeviceStatus.disconnected);
    });
  }

  void pausePolling() => _stopPolling();

  void resumePolling() {
    if (state.status == DeviceStatus.connected) {
      _startPolling();
    }
  }

  void _startPolling() {
    _stopPolling();
    _pollingTimer = Timer.periodic(
      const Duration(milliseconds: AppConstants.telemetryPollingIntervalMs),
      (_) => _pollStatus(),
    );
  }

  Future<void> _pollStatus() async {
    if (state.status != DeviceStatus.connected) {
      _stopPolling();
      return;
    }

    final result = await ref
        .read(getDeviceStatusUseCaseProvider)
        .call(const NoParams());

    result.fold((device) => state = device, (failure) {
      _stopPolling();
      state = Device(
        status: DeviceStatus.error,
        errorMessage: 'Связь потеряна: ${failure.message}',
      );
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}

final deviceConnectionNotifierProvider =
    NotifierProvider<DeviceConnectionNotifier, Device>(
      DeviceConnectionNotifier.new,
    );
