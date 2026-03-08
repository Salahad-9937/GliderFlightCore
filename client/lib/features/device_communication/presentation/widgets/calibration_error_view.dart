import 'package:flutter/material.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';

/// Виджет отображения ошибки в процессе калибровки.
class CalibrationErrorView extends StatelessWidget {
  final String? error;
  final AppStrings strings;
  final VoidCallback onRetry;

  const CalibrationErrorView({
    super.key,
    this.error,
    required this.strings,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline, color: AppColors.error, size: 48),
        const SizedBox(height: 16),
        Text(
          error?.t ?? 'CALIB_ERROR'.t,
          style: AppTextStyles.instrumentLabel.copyWith(color: AppColors.error),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton(onPressed: onRetry, child: Text(strings.core.retry.t)),
      ],
    );
  }
}
