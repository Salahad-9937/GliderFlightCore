import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/flight_programs/domain/entities/flight_program.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';

/// Notifier для управления состоянием подключения к устройству.
/// Реализует логику периодического опроса (Polling).
class DeviceConnectionNotifier extends Notifier<Device> {
  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);
  Timer? _pollingTimer;

  @override
  Device build() {
    // При уничтожении провайдера обязательно останавливаем таймер
    ref.onDispose(() {
      _stopPolling();
    });
    return const Device(status: DeviceStatus.disconnected);
  }

  /// Инициирует подключение к устройству.
  Future<void> connect() async {
    state = state.copyWith(status: DeviceStatus.connecting);
    
    // Делаем первый запрос
    final result = await _repository.connectToDeviceAP();
    state = result;

    // Если подключение успешно, запускаем периодический опрос
    if (state.status == DeviceStatus.connected) {
      _startPolling();
    }
  }

  /// Запускает таймер опроса статуса.
  void _startPolling() {
    _stopPolling(); // На всякий случай сбрасываем предыдущий
    // Опрашиваем каждые 500 мс для плавности UI
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      // Если мы вдруг отключились (логически), останавливаем таймер
      if (state.status != DeviceStatus.connected && state.status != DeviceStatus.connecting) {
        _stopPolling();
        return;
      }

      // Выполняем "тихий" запрос обновления.
      // Не переводим статус в connecting, чтобы не мигал UI.
      final result = await _repository.connectToDeviceAP();
      
      if (result.status == DeviceStatus.connected) {
        // Обновляем состояние новыми данными телеметрии
        state = result; 
      } else {
        // Если произошла ошибка связи во время опроса
        // Можно либо сразу рвать соединение, либо дать пару шансов.
        // Пока рвем сразу для надежности индикации.
        _stopPolling();
        state = result; // Переведет в error
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Загружает полетную программу на устройство.
  Future<bool> uploadProgram(FlightProgram program) async {
    if (state.status != DeviceStatus.connected || state.ipAddress == null) {
      return false;
    }
    // Временно приостанавливаем опрос, чтобы не забивать канал во время загрузки
    _stopPolling();
    final success = await _repository.uploadProgram(state.ipAddress!, program);
    // Возобновляем опрос
    _startPolling();
    return success;
  }

  /// Сбрасывает состояние подключения.
  void disconnect() {
    _stopPolling();
    state = const Device(status: DeviceStatus.disconnected);
  }
}

/// Провайдер для Notifier-а, управляющего состоянием подключения.
final deviceConnectionNotifierProvider =
    NotifierProvider<DeviceConnectionNotifier, Device>(
  DeviceConnectionNotifier.new,
);