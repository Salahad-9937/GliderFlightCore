import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device.dart';
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
  
  @override
  CalibrationState build() {
    ref.listen<Device>(deviceConnectionNotifierProvider, (previous, next) {
      _handleDeviceUpdate(next);
    });
    
    return const CalibrationState();
  }

  void _handleDeviceUpdate(Device next) {
    // 1. Потеря связи
    if (next.status != DeviceStatus.connected) {
      if (state.phase != CalibrationPhase.idle && state.phase != CalibrationPhase.error) {
        state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Связь потеряна');
      }
      return;
    }

    // 2. Устройство в процессе калибровки
    if (next.isCalibrating) {
      final phase = _mapPhase(next.calibrationPhase);
      final progress = (next.calibrationProgress ?? 0) / 100.0;
      
      // Обновляем UI только данными с устройства
      state = CalibrationState(phase: phase, progress: progress);
    } 
    // 3. Устройство НЕ калибруется (IDLE)
    else {
      // Если UI показывал прогресс, а устройство закончило
      final isUiThinkingItIsCalibrating = 
          state.phase == CalibrationPhase.stabilization ||
          state.phase == CalibrationPhase.measuring ||
          state.phase == CalibrationPhase.zeroing;

      if (isUiThinkingItIsCalibrating) {
        if (next.isCalibrated) {
          state = const CalibrationState(phase: CalibrationPhase.success, progress: 1.0);
        } else {
          // Если флаг calibrated не стоит, значит была отмена или ошибка
          state = const CalibrationState(phase: CalibrationPhase.idle);
        }
      }
    }
  }

  CalibrationPhase _mapPhase(String? phaseStr) {
    switch (phaseStr) {
      case 'stabilization': return CalibrationPhase.stabilization;
      case 'measuring': return CalibrationPhase.measuring;
      case 'zeroing': return CalibrationPhase.zeroing;
      default: return CalibrationPhase.idle;
    }
  }

  Future<bool> zeroAltitude() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Нет подключения');
      return false;
    }

    // УБРАНО: state = const CalibrationState(phase: CalibrationPhase.zeroing...);
    // Ждем, пока поллинг сам подхватит изменение статуса

    final success = await _repository.zeroAltitude(device.ipAddress!);
    if (!success) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Ошибка отправки команды');
      return false;
    }
    return true;
  }

  Future<void> startFullCalibration() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Нет подключения');
      return;
    }

    // УБРАНО: state = const CalibrationState(phase: CalibrationPhase.stabilization...);

    final success = await _repository.startCalibration(device.ipAddress!);
    if (!success) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Ошибка запуска');
    }
  }

  Future<void> cancelOperation() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) return;

    await _repository.cancelCalibration(device.ipAddress!);
    // При отмене сбрасываем сразу для отзывчивости
    state = const CalibrationState(phase: CalibrationPhase.idle);
  }

  Future<void> saveCalibration() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) return;

    await _repository.saveCalibration(device.ipAddress!);
    state = const CalibrationState(phase: CalibrationPhase.idle);
  }
  
  void reset() {
    state = const CalibrationState(phase: CalibrationPhase.idle);
  }
}

final sensorCalibrationProvider = NotifierProvider<SensorCalibrationNotifier, CalibrationState>(
  SensorCalibrationNotifier.new,
);