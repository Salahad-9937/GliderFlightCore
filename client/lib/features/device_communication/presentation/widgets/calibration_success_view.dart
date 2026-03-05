import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Виджет состояния успешного завершения калибровки.
class CalibrationSuccessView extends StatelessWidget {
  final dynamic strings;
  final VoidCallback onSave;

  const CalibrationSuccessView({
    super.key,
    required this.strings,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.check_circle_outline,
          color: AppColors.success,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          strings.comm.calibSuccess.t,
          style: AppTextStyles.instrumentLabel.copyWith(
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: onSave,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.black,
          ),
          child: Text(
            strings.comm.saveToMemoryBtn.t,
            style: AppTextStyles.button,
          ),
        ),
      ],
    );
  }
}
