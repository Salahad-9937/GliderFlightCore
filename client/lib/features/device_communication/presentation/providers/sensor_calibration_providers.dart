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
    // Подписываемся на изменения состояния устройства
    ref.listen<Device>(deviceConnectionNotifierProvider, (previous, next) {
      _handleDeviceUpdate(next);
    });
    
    return const CalibrationState();
  }

  /// Обработка обновлений от устройства.
  /// Логика основана на текущем состоянии UI и пришедшем состоянии устройства.
  void _handleDeviceUpdate(Device next) {
    // 1. Если связь потеряна - сразу ошибка
    if (next.status != DeviceStatus.connected) {
      if (state.phase != CalibrationPhase.idle && state.phase != CalibrationPhase.error) {
        state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Связь потеряна');
      }
      return;
    }

    // 2. Если устройство сообщает, что идет процесс
    if (next.isCalibrating) {
      final phase = _mapPhase(next.calibrationPhase);
      final progress = (next.calibrationProgress ?? 0) / 100.0;
      
      // Просто синхронизируем UI с устройством
      state = CalibrationState(phase: phase, progress: progress);
    } 
    // 3. Если устройство сообщает, что процесс НЕ идет (IDLE)
    else {
      // Проверяем, находится ли наш UI в режиме ожидания завершения
      // (то есть мы показываем прогресс-бар, а плата уже всё)
      final isUiThinkingItIsCalibrating = 
          state.phase == CalibrationPhase.stabilization ||
          state.phase == CalibrationPhase.measuring ||
          state.phase == CalibrationPhase.zeroing;

      if (isUiThinkingItIsCalibrating) {
        // Процесс завершился. Проверяем результат.
        if (next.isCalibrated) {
          state = const CalibrationState(phase: CalibrationPhase.success, progress: 1.0);
        } else {
          // Если флаг calibrated не стоит, значит что-то пошло не так
          state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Сбой калибровки');
        }
      }
    }
  }

  /// Маппинг строковых статусов с прошивки в Enum приложения
  CalibrationPhase _mapPhase(String? phaseStr) {
    switch (phaseStr) {
      case 'stabilization': return CalibrationPhase.stabilization;
      case 'measuring': return CalibrationPhase.measuring;
      case 'zeroing': return CalibrationPhase.zeroing;
      default: return CalibrationPhase.idle;
    }
  }

  /// Быстрое обнуление высоты.
  Future<bool> zeroAltitude() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Нет подключения');
      return false;
    }

    // Ставим UI в режим ожидания, чтобы _handleDeviceUpdate подхватил процесс
    state = const CalibrationState(phase: CalibrationPhase.zeroing, progress: 0.0);

    final success = await _repository.zeroAltitude(device.ipAddress!);
    
    if (!success) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Ошибка отправки команды');
      return false;
    }
    return true;
  }

  /// Запуск полной калибровки.
  Future<void> startFullCalibration() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Нет подключения');
      return;
    }

    // Ставим UI в режим ожидания
    state = const CalibrationState(phase: CalibrationPhase.stabilization, progress: 0.0);

    final success = await _repository.startCalibration(device.ipAddress!);
    if (!success) {
      state = const CalibrationState(phase: CalibrationPhase.error, errorMessage: 'Ошибка запуска');
    }
  }

  /// Сохранение результатов.
  Future<void> saveCalibration() async {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected || device.ipAddress == null) return;

    await _repository.saveCalibration(device.ipAddress!);
    
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