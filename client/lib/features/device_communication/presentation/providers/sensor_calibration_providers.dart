import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';
import 'device_connection_providers.dart';

/// Этапы процесса калибровки.
enum CalibrationPhase {
  idle,           // Ожидание
  zeroing,        // Обнуление (быстрое)
  stabilization,  // Термостабилизация
  measuring,      // Сбор данных
  success,        // Успешно завершено
  error,          // Ошибка
}

/// Состояние процесса калибровки.
class CalibrationState {
  final CalibrationPhase phase;
  final double progress; // 0.0 ... 1.0
  final String? errorMessage;

  const CalibrationState({
    this.phase = CalibrationPhase.idle,
    this.progress = 0.0,
    this.errorMessage,
  });
}

/// Контроллер для управления калибровкой.
class SensorCalibrationNotifier extends Notifier<CalibrationState> {
  DeviceRepository get _repository => ref.read(deviceRepositoryProvider);
  
  // Флаг для отслеживания жизненного цикла провайдера
  bool _mounted = true;

  @override
  CalibrationState build() {
    ref.onDispose(() {
      _mounted = false;
    });
    return const CalibrationState();
  }

  /// Быстрое обнуление высоты с анимацией прогресса.
  /// Возвращает true, если успешно.
  Future<bool> zeroAltitude() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Нет подключения');
      return false;
    }

    // 1. Устанавливаем фазу обнуления
    state = const CalibrationState(phase: CalibrationPhase.zeroing, progress: 0.0);

    // 2. Запускаем запрос к плате (он длится ~1 сек на устройстве)
    final requestFuture = _repository.zeroAltitude(device.ipAddress!);

    // 3. Параллельно запускаем анимацию прогресса (1 секунда)
    const steps = 10;
    for (int i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_mounted) return false;
      // Обновляем прогресс, только если мы всё еще в фазе обнуления
      if (state.phase == CalibrationPhase.zeroing) {
        state = CalibrationState(phase: CalibrationPhase.zeroing, progress: i / steps);
      }
    }

    // 4. Дожидаемся реального ответа от платы
    final success = await requestFuture;

    if (!_mounted) return false;

    if (success) {
      // Сбрасываем в idle, чтобы UI мог закрыться или обновиться
      state = const CalibrationState(phase: CalibrationPhase.idle);
      return true;
    } else {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Ошибка обнуления');
      return false;
    }
  }

  /// Запуск полной калибровки с симуляцией этапов.
  Future<void> startFullCalibration() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Нет подключения');
      return;
    }

    // 1. Отправляем команду на плату
    final success = await _repository.startCalibration(device.ipAddress!);
    if (!success) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Ошибка запуска');
      return;
    }

    // 2. Симуляция: Термостабилизация
    if (!_mounted) return;
    state = const CalibrationState(phase: CalibrationPhase.stabilization, progress: 0.0);
    
    const stabilizationSteps = 50; 
    for (int i = 1; i <= stabilizationSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_mounted) return;
      state = CalibrationState(
        phase: CalibrationPhase.stabilization,
        progress: i / stabilizationSteps,
      );
    }

    // 3. Симуляция: Сбор данных
    if (!_mounted) return;
    state = const CalibrationState(phase: CalibrationPhase.measuring, progress: 0.0);
    
    const measuringSteps = 50;
    for (int i = 1; i <= measuringSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!_mounted) return;
      state = CalibrationState(
        phase: CalibrationPhase.measuring,
        progress: i / measuringSteps,
      );
    }

    // 4. Завершение
    if (!_mounted) return;
    state = const CalibrationState(phase: CalibrationPhase.success, progress: 1.0);
  }

  /// Сохранение результатов.
  Future<void> saveCalibration() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) return;

    await _repository.saveCalibration(device.ipAddress!);
    
    if (!_mounted) return;
    state = const CalibrationState(phase: CalibrationPhase.idle);
  }
  
  /// Сброс UI в исходное состояние.
  void reset() {
    state = const CalibrationState(phase: CalibrationPhase.idle);
  }
}

final sensorCalibrationProvider = NotifierProvider<SensorCalibrationNotifier, CalibrationState>(
  SensorCalibrationNotifier.new,
);