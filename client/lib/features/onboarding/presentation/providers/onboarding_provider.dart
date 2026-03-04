import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';

part 'onboarding_provider.g.dart';

/// Состояние Onboarding.
class OnboardingState {
  final bool isCompleted;
  const OnboardingState({required this.isCompleted});
}

/// Контроллер процесса приветствия.
///
/// Использует [keepAlive: true], чтобы состояние сохранялось в течение всей сессии.
@Riverpod(keepAlive: true)
class Onboarding extends _$Onboarding {
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
