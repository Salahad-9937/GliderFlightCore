import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_content.dart';
import '../widgets/onboarding_footer.dart';
import '../widgets/onboarding_logo.dart';

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
              const OnboardingLogo(),
              const SizedBox(height: 60),
              OnboardingContent(
                title: strings.onboarding.welcomeTitle,
                description: strings.onboarding.welcomeDesc,
              ),
              const Spacer(),
              OnboardingFooter(
                buttonText: strings.onboarding.startBtn,
                versionText: strings.onboarding.systemVersion,
                onStart: notifier.completeOnboarding,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
