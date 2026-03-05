import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';

/// Нижняя часть экрана с кнопкой запуска и версией.
class OnboardingFooter extends StatelessWidget {
  final String buttonText;
  final String versionText;
  final VoidCallback onStart;

  const OnboardingFooter({
    super.key,
    required this.buttonText,
    required this.versionText,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: FilledButton(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ),
            child: Text(
              buttonText.t,
              style: AppTextStyles.button.copyWith(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          versionText,
          style: AppTextStyles.instrumentLabel.copyWith(fontSize: 9),
        ),
      ],
    );
  }
}
