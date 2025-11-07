import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';

/// Notifier для управления состоянием подключения к устройству.
class DeviceConnectionNotifier extends Notifier<Device> {
  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);

  @override
  Device build() {
    // Начальное состояние - не подключено.
    return const Device(status: DeviceStatus.disconnected);
  }

  /// Инициирует подключение к устройству в режиме точки доступа.
  Future<void> connect() async {
    state = state.copyWith(status: DeviceStatus.connecting);
    // Вызываем метод репозитория и обновляем состояние результатом.
    state = await _repository.connectToDeviceAP();
  }

  /// Сбрасывает состояние подключения.
  void disconnect() {
    state = const Device(status: DeviceStatus.disconnected);
  }
}

/// Провайдер для Notifier-а, управляющего состоянием подключения.
final deviceConnectionNotifierProvider =
    NotifierProvider<DeviceConnectionNotifier, Device>(
  DeviceConnectionNotifier.new,
);