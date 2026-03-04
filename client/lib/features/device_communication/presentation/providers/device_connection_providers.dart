import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/architecture/use_case.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/core_providers.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import 'device_usecase_providers.dart';
import 'sensor_settings_controller.dart';

part 'device_connection_providers.g.dart';

/// Нотификатор управления сессией связи с устройством.
@Riverpod(keepAlive: true)
class DeviceConnection extends _$DeviceConnection {
  Timer? _pollingTimer;
  int _consecutiveFailures = 0;

  @override
  Device build() {
    ref.onDispose(() => _stopPolling());
    return const Device(status: DeviceStatus.disconnected);
  }

  /// Обработка изменения состояния жизненного цикла приложения.
  /// Вынесено из UI для соблюдения Layering.
  Future<void> handleLifecycleChange(AppLifecycleState state) async {
    if (this.state.status != DeviceStatus.connected) return;

    final settings = ref.read(sensorSettingsControllerProvider);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      pausePolling();
      await settings.toggleMonitoring(false);
    } else if (state == AppLifecycleState.resumed) {
      await settings.toggleMonitoring(true);
      resumePolling();
    }
  }

  Future<void> connect() async {
    if (state.status == DeviceStatus.connecting) return;

    if (state.status == DeviceStatus.connected) {
      _startPolling();
      await ref.read(sensorSettingsControllerProvider).toggleMonitoring(true);
      return;
    }

    state = state.copyWith(status: DeviceStatus.connecting);
    _consecutiveFailures = 0;

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
        ref
            .read(loggerServiceProvider)
            .e('Ошибка подключения: ${failure.message}');
        state = Device(
          status: DeviceStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  void disconnect() {
    _stopPolling();
    if (state.status == DeviceStatus.connected) {
      ref.read(toggleMonitoringUseCaseProvider).call(false);
    }
    Timer.run(() => state = const Device(status: DeviceStatus.disconnected));
  }

  void pausePolling() => _stopPolling();

  void resumePolling() {
    if (state.status == DeviceStatus.connected) _startPolling();
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

    result.fold(
      (device) {
        _consecutiveFailures = 0;
        state = device;
      },
      (failure) {
        _consecutiveFailures++;
        ref
            .read(loggerServiceProvider)
            .w(
              'Сбой опроса ($_consecutiveFailures/${AppConstants.maxConsecutiveFailures}): ${failure.message}',
            );

        if (_consecutiveFailures >= AppConstants.maxConsecutiveFailures) {
          final strings = ref.read(l10nProvider);
          _stopPolling();
          state = Device(
            status: DeviceStatus.error,
            errorMessage: '${strings.comm.connectionLost}: ${failure.message}',
          );
        }
      },
    );
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}
