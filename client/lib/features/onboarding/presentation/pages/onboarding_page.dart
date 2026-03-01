import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';

/// Экран приветствия в стиле инициализации бортового компьютера.
class OnboardingPage extends ConsumerWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);
    final notifier = ref.read(onboardingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Анимированный логотип/иконка
              Container(
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
              ),
              const SizedBox(height: 60),
              Text(
                strings.onboarding.welcomeTitle.toUpperCase(),
                style: AppTextStyles.telemetryValueLarge.copyWith(
                  fontSize: 28,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  strings.onboarding.welcomeDesc.toUpperCase(),
                  style: AppTextStyles.instrumentLabel.copyWith(
                    color: Colors.grey,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(),
              // Тактическая кнопка
              SizedBox(
                width: double.infinity,
                height: 60,
                child: FilledButton(
                  onPressed: notifier.completeOnboarding,
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
                    strings.onboarding.startBtn.toUpperCase(),
                    style: AppTextStyles.button.copyWith(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "SYSTEM VERSION 1.2.0 // READY",
                style: AppTextStyles.instrumentLabel.copyWith(fontSize: 9),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
