import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/core_providers.dart';
import 'core/theme/app_theme.dart';
import 'features/glider_profiles/presentation/pages/glider_profiles_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/onboarding/presentation/providers/onboarding_provider.dart';

void main() async {
  // Гарантируем инициализацию биндингов Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация SharedPreferences перед запуском приложения
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        // Переопределяем провайдер реальным экземпляром SharedPreferences
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MyApp(),
    ),
  );
}

/// Корневой виджет приложения.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Следим за состоянием завершенности приветствия
    final onboardingState = ref.watch(onboardingProvider);

    return MaterialApp(
      title: 'Glider Flight Core',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      // Если приветствие не пройдено — показываем OnboardingPage
      home: onboardingState.isCompleted
          ? const GliderProfilesPage()
          : const OnboardingPage(),
    );
  }
}
