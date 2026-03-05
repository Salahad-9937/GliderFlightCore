import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Визуальный компонент логотипа для экрана приветствия.
class OnboardingLogo extends StatelessWidget {
  const OnboardingLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Icon(
        Icons.airplanemode_active,
        size: 80,
        color: AppColors.primary,
      ),
    );
  }
}
