import 'parts/core_strings.dart';
import 'parts/comm_strings.dart';
import 'parts/prog_strings.dart';
import 'parts/panel_strings.dart';
import 'parts/profile_strings.dart';
import 'parts/onboarding_strings.dart'; // Добавлено

/// Главный контейнер локализации.
class AppStrings {
  final String appTitle;

  final CoreStrings core;
  final CommStrings comm;
  final ProgStrings prog;
  final PanelStrings panel;
  final ProfileStrings profiles;
  final OnboardingStrings onboarding; // Добавлено

  const AppStrings({
    required this.appTitle,
    required this.core,
    required this.comm,
    required this.prog,
    required this.panel,
    required this.profiles,
    required this.onboarding, // Добавлено
  });

  static const ru = AppStrings(
    appTitle: 'Glider Flight Core',
    core: CoreStrings.ru,
    comm: CommStrings.ru,
    prog: ProgStrings.ru,
    panel: PanelStrings.ru,
    profiles: ProfileStrings.ru,
    onboarding: OnboardingStrings.ru, // Добавлено
  );
}
