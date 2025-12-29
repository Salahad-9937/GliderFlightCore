import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';
import 'sensor_settings_controller.dart';

class DeviceConnectionNotifier extends Notifier<Device> {
  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);
  Timer? _pollingTimer;

  @override
  Device build() {
    ref.onDispose(() => _stopPolling());
    return const Device(status: DeviceStatus.disconnected);
  }

  Future<void> connect() async {
    if (state.status == DeviceStatus.connecting) return;

    if (state.status == DeviceStatus.connected) {
      _startPolling();
      await ref.read(sensorSettingsControllerProvider).toggleMonitoring(true);
      return;
    }

    state = state.copyWith(status: DeviceStatus.connecting);

    final result = await _repository.connectToDeviceAP();

    if (result.status == DeviceStatus.connected) {
      state = result;
      await ref.read(sensorSettingsControllerProvider).toggleMonitoring(true);
      _startPolling();
    } else {
      state = result;
    }
  }

  void disconnect() {
    _stopPolling();

    final lastIp = state.ipAddress;
    final wasConnected = state.status == DeviceStatus.connected;

    if (wasConnected && lastIp != null) {
      _repository.setSensorMonitoring(lastIp, false);
    }

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
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (
      _,
    ) async {
      if (state.status != DeviceStatus.connected) {
        _stopPolling();
        return;
      }

      try {
        final result = await _repository.connectToDeviceAP();
        if (result.status == DeviceStatus.connected) {
          state = result;
        } else {
          _stopPolling();
          state = result;
        }
      } catch (e) {
        _stopPolling();
        state = const Device(
          status: DeviceStatus.error,
          errorMessage: 'Связь потеряна',
        );
      }
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
