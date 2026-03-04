import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/architecture/use_case.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import 'device_connection_providers.dart';
import 'device_usecase_providers.dart';

part 'sensor_calibration_providers.g.dart';

enum CalibrationPhase {
  idle,
  zeroing,
  stabilization,
  measuring,
  success,
  error,
}

class CalibrationState {
  final CalibrationPhase phase;
  final double progress;
  final String? errorMessage;

  const CalibrationState({
    this.phase = CalibrationPhase.idle,
    this.progress = 0.0,
    this.errorMessage,
  });

  /// Геттер для строкового представления прогресса.
  String get progressLabel => '${(progress * 100).toInt()}%';

  /// Геттер для выбора цвета на основе фазы.
  Color get phaseColor {
    return switch (phase) {
      CalibrationPhase.zeroing => AppColors.accent,
      CalibrationPhase.stabilization => AppColors.warning,
      CalibrationPhase.measuring => AppColors.primary,
      CalibrationPhase.success => AppColors.success,
      CalibrationPhase.error => AppColors.error,
      _ => AppColors.border,
    };
  }
}

@riverpod
class SensorCalibration extends _$SensorCalibration {
  @override
  CalibrationState build() {
    ref.listen<Device>(deviceConnectionProvider, (previous, next) {
      _handleDeviceUpdate(next);
    });
    return const CalibrationState();
  }

  void _handleDeviceUpdate(Device next) {
    if (next.status != DeviceStatus.connected) {
      if (state.phase != CalibrationPhase.idle &&
          state.phase != CalibrationPhase.error) {
        state = const CalibrationState(
          phase: CalibrationPhase.error,
          errorMessage: 'Связь потеряна',
        );
      }
      return;
    }

    if (next.isCalibrating) {
      state = CalibrationState(
        phase: _mapPhase(next.calibrationPhase),
        progress: (next.calibrationProgress ?? 0) / 100.0,
      );
    } else {
      final isUiActive =
          state.phase == CalibrationPhase.stabilization ||
          state.phase == CalibrationPhase.measuring ||
          state.phase == CalibrationPhase.zeroing;

      if (isUiActive) {
        state = next.isCalibrated
            ? const CalibrationState(
                phase: CalibrationPhase.success,
                progress: 1.0,
              )
            : const CalibrationState(phase: CalibrationPhase.idle);
      }
    }
  }

  CalibrationPhase _mapPhase(String? phaseStr) {
    return switch (phaseStr) {
      'stabilization' => CalibrationPhase.stabilization,
      'measuring' => CalibrationPhase.measuring,
      'zeroing' => CalibrationPhase.zeroing,
      _ => CalibrationPhase.idle,
    };
  }

  Future<bool> zeroAltitude() async {
    final result = await ref
        .read(zeroAltitudeUseCaseProvider)
        .call(const NoParams());
    return result.fold((_) => true, (f) {
      state = CalibrationState(
        phase: CalibrationPhase.error,
        errorMessage: f.message,
      );
      return false;
    });
  }

  Future<void> startFullCalibration() async {
    final result = await ref
        .read(startCalibrationUseCaseProvider)
        .call(const NoParams());
    result.fold(
      (_) => null,
      (f) => state = CalibrationState(
        phase: CalibrationPhase.error,
        errorMessage: f.message,
      ),
    );
  }

  Future<void> cancelOperation() async {
    await ref.read(cancelOperationUseCaseProvider).call(const NoParams());
    state = const CalibrationState(phase: CalibrationPhase.idle);
  }

  Future<void> saveCalibration() async {
    await ref.read(saveCalibrationUseCaseProvider).call(const NoParams());
    state = const CalibrationState(phase: CalibrationPhase.idle);
  }

  void reset() => state = const CalibrationState(phase: CalibrationPhase.idle);
}
