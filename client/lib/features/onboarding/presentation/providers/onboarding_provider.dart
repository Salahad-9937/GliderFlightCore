import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';

/// Состояние Onboarding (просто флаг).
class OnboardingState {
  final bool isCompleted;
  const OnboardingState({required this.isCompleted});
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  static const _key = 'onboarding_completed';

  @override
  OnboardingState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    // Если ключа нет, значит это первый запуск (false)
    final isDone = prefs.getBool(_key) ?? false;
    return OnboardingState(isCompleted: isDone);
  }

  /// Помечает приветствие как пройденное.
  Future<void> completeOnboarding() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(_key, true);
    state = const OnboardingState(isCompleted: true);
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
