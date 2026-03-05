import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../providers/sensor_calibration_providers.dart';

/// Виджет отображения текущего прогресса фазы калибровки.
class CalibrationPhaseView extends StatelessWidget {
  final String label;
  final CalibrationState state;

  const CalibrationPhaseView({
    super.key,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.t,
          style: AppTextStyles.instrumentLabel.copyWith(
            color: state.phaseColor,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: state.progress,
            minHeight: 8,
            color: state.phaseColor,
            backgroundColor: AppColors.surface,
          ),
        ),
        const SizedBox(height: 8),
        Text(state.progressLabel, style: AppTextStyles.instrumentLabel),
      ],
    );
  }
}
