import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../providers/sensor_calibration_providers.dart';
import 'calibration_error_view.dart';
import 'calibration_phase_view.dart';
import 'calibration_success_view.dart';

/// Терминал калибровки датчиков.
class CalibrationBottomSheet extends ConsumerWidget {
  const CalibrationBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibState = ref.watch(sensorCalibrationProvider);
    final notifier = ref.read(sensorCalibrationProvider.notifier);
    final strings = ref.watch(l10nProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.primary, width: 2)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHandle(),
              const SizedBox(height: 24),
              Text(
                strings.comm.calibrationTitle.t,
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildContent(calibState, notifier, strings),
              _buildCancelButton(calibState, notifier, strings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    CalibrationState state,
    SensorCalibration notifier,
    dynamic strings,
  ) {
    return switch (state.phase) {
      CalibrationPhase.idle || CalibrationPhase.success => Column(
        children: [
          _actionBtn(
            strings.comm.zeroAltitudeBtn,
            Icons.exposure_zero,
            notifier.zeroAltitude,
            AppColors.accent,
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border),
          const SizedBox(height: 16),
          if (state.phase == CalibrationPhase.idle)
            _actionBtn(
              strings.comm.startFullCalibBtn,
              Icons.settings_backup_restore,
              notifier.startFullCalibration,
              AppColors.primary,
            )
          else
            CalibrationSuccessView(
              strings: strings,
              onSave: notifier.saveCalibration,
            ),
        ],
      ),
      CalibrationPhase.zeroing => CalibrationPhaseView(
        label: strings.comm.zeroingProcess,
        state: state,
      ),
      CalibrationPhase.stabilization => CalibrationPhaseView(
        label: strings.comm.stabilizationProcess,
        state: state,
      ),
      CalibrationPhase.measuring => CalibrationPhaseView(
        label: strings.comm.measuringProcess,
        state: state,
      ),
      CalibrationPhase.error => CalibrationErrorView(
        error: state.errorMessage,
        strings: strings,
        onRetry: notifier.reset,
      ),
    };
  }

  Widget _actionBtn(
    String label,
    IconData icon,
    VoidCallback onPressed,
    Color color,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label.t, style: AppTextStyles.button),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildCancelButton(
    CalibrationState state,
    SensorCalibration notifier,
    dynamic strings,
  ) {
    if (state.phase == CalibrationPhase.idle ||
        state.phase == CalibrationPhase.success) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: TextButton(
        onPressed: notifier.cancelOperation,
        child: Text(
          strings.comm.cancelOperation.t,
          style: AppTextStyles.button.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}
