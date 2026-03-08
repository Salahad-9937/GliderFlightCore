import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/architecture/use_case.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import 'device_usecase_providers.dart';
import 'sensor_settings_controller.dart';

part 'device_connection_providers.g.dart';

/// Нотификатор управления сессией связи.
/// Использует autoDispose для автоматического управления ресурсами.
@riverpod
class DeviceConnection extends _$DeviceConnection {
  Timer? _pollingTimer;
  int _consecutiveFailures = 0;

  @override
  Device build() {
    // Ресурс уничтожается автоматически, когда все виджеты перестают слушать провайдер.
    ref.onDispose(() => _stopPolling());

    // Инициируем подключение при первой активации провайдера.
    // Используем microtask, так как модификация состояния (внутри connect)
    // запрещена непосредственно во время выполнения build.
    Future.microtask(() => connect());

    // Возвращаем начальное состояние. До завершения build обращение к state запрещено.
    return const Device(status: DeviceStatus.disconnected);
  }

  /// Управление через жизненный цикл приложения.
  /// Вызывается только если провайдер активен.
  Future<void> handleLifecycleChange(AppLifecycleState lifecycleState) async {
    if (state.status != DeviceStatus.connected) return;

    final settings = ref.read(sensorSettingsControllerProvider);

    if (lifecycleState == AppLifecycleState.paused ||
        lifecycleState == AppLifecycleState.inactive) {
      pausePolling();
      await settings.toggleMonitoring(false);
    } else if (lifecycleState == AppLifecycleState.resumed) {
      await settings.toggleMonitoring(true);
      resumePolling();
    }
  }

  /// Инициация подключения к устройству.
  Future<void> connect() async {
    if (state.status == DeviceStatus.connecting) return;

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
        state = Device(
          status: DeviceStatus.error,
          errorMessage: failure.message,
        );
      },
    );
  }

  /// Ручное отключение и сброс состояния.
  void disconnect() {
    _stopPolling();
    if (state.status == DeviceStatus.connected) {
      ref.read(toggleMonitoringUseCaseProvider).call(false);
    }
    state = const Device(status: DeviceStatus.disconnected);
  }

  /// Остановка таймера опроса.
  void pausePolling() => _stopPolling();

  /// Возобновление опроса, если соединение активно.
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
    if (state.status != DeviceStatus.connected) return;

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
        if (_consecutiveFailures >= AppConstants.maxConsecutiveFailures) {
          _stopPolling();
          state = Device(
            status: DeviceStatus.error,
            errorMessage: failure.message,
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
