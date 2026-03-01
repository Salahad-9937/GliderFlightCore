import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/sensor_calibration_providers.dart';

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
      // SafeArea внутри шторки гарантирует, что кнопки не уйдут под Navigation Bar
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                strings.comm.calibrationTitle.toUpperCase(),
                style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Быстрое обнуление
              if (calibState.phase == CalibrationPhase.idle ||
                  calibState.phase == CalibrationPhase.success)
                _buildActionButton(
                  label: strings.comm.zeroAltitudeBtn,
                  icon: Icons.exposure_zero,
                  onPressed: notifier.zeroAltitude,
                  color: AppColors.accent,
                ),

              if (calibState.phase == CalibrationPhase.zeroing)
                _buildProgress(
                  strings.comm.zeroingProcess,
                  calibState.progress,
                  AppColors.accent,
                ),

              const SizedBox(height: 16),
              const Divider(color: AppColors.border),
              const SizedBox(height: 16),

              // Полная калибровка
              if (calibState.phase == CalibrationPhase.idle)
                _buildActionButton(
                  label: strings.comm.startFullCalibBtn,
                  icon: Icons.settings_backup_restore,
                  onPressed: notifier.startFullCalibration,
                  color: AppColors.primary,
                )
              else if (calibState.phase == CalibrationPhase.stabilization)
                _buildProgress(
                  strings.comm.stabilizationProcess,
                  calibState.progress,
                  AppColors.warning,
                )
              else if (calibState.phase == CalibrationPhase.measuring)
                _buildProgress(
                  strings.comm.measuringProcess,
                  calibState.progress,
                  AppColors.primary,
                )
              else if (calibState.phase == CalibrationPhase.success)
                _buildSuccess(notifier, strings)
              else if (calibState.phase == CalibrationPhase.error)
                _buildError(notifier, calibState.errorMessage, strings),

              if (calibState.phase != CalibrationPhase.idle &&
                  calibState.phase != CalibrationPhase.success)
                Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: TextButton(
                    onPressed: notifier.cancelOperation,
                    child: Text(
                      strings.comm.cancelOperation.toUpperCase(),
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label.toUpperCase(), style: AppTextStyles.button),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Widget _buildProgress(String label, double progress, Color color) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.instrumentLabel.copyWith(color: color),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            color: color,
            backgroundColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: AppTextStyles.instrumentLabel,
        ),
      ],
    );
  }

  Widget _buildSuccess(dynamic notifier, dynamic strings) {
    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          strings.comm.calibSuccess.toUpperCase(),
          style: AppTextStyles.instrumentLabel.copyWith(
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () {
            notifier.saveCalibration();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.black,
          ),
          child: Text(
            strings.comm.saveToMemoryBtn.toUpperCase(),
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }

  Widget _buildError(dynamic notifier, String? error, dynamic strings) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
        const SizedBox(height: 16),
        Text(
          error?.toUpperCase() ?? 'CALIB_ERROR',
          style: AppTextStyles.instrumentLabel.copyWith(color: AppColors.error),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: notifier.reset,
          child: Text(strings.core.retry.toUpperCase()),
        ),
      ],
    );
  }
}
