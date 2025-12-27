import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';

/// Notifier для управления состоянием подключения к устройству.
///
/// Ответственность:
/// - Установка и разрыв соединения.
/// - Периодический опрос статуса (Polling).
/// - Предоставление методов для временной приостановки опроса (для других контроллеров).
class DeviceConnectionNotifier extends Notifier<Device> {
  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);
  Timer? _pollingTimer;

  @override
  Device build() {
    ref.onDispose(() {
      _stopPolling();
    });
    return const Device(status: DeviceStatus.disconnected);
  }

  /// Инициирует подключение к устройству.
  Future<void> connect() async {
    state = state.copyWith(status: DeviceStatus.connecting);
    
    final result = await _repository.connectToDeviceAP();
    state = result;

    if (state.status == DeviceStatus.connected) {
      _startPolling();
    }
  }

  /// Сбрасывает состояние подключения.
  void disconnect() {
    _stopPolling();
    state = const Device(status: DeviceStatus.disconnected);
  }

  /// Приостанавливает опрос (используется внешними контроллерами перед тяжелыми операциями).
  void pausePolling() {
    _stopPolling();
  }

  /// Возобновляет опрос (если устройство подключено).
  void resumePolling() {
    if (state.status == DeviceStatus.connected) {
      _startPolling();
    }
  }

  // --- Внутренняя логика Polling ---

  void _startPolling() {
    _stopPolling(); 
    // Опрашиваем каждые 500 мс
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      if (state.status != DeviceStatus.connected && state.status != DeviceStatus.connecting) {
        _stopPolling();
        return;
      }

      final result = await _repository.connectToDeviceAP();
      
      if (result.status == DeviceStatus.connected) {
        state = result; 
      } else {
        _stopPolling();
        state = result; // Переход в ошибку
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }
}

/// Провайдер для Notifier-а, управляющего состоянием подключения.
final deviceConnectionNotifierProvider =
    NotifierProvider<DeviceConnectionNotifier, Device>(
  DeviceConnectionNotifier.new,
);