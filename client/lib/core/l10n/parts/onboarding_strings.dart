/// Строки для экрана приветствия.
class OnboardingStrings {
  final String welcomeTitle;
  final String welcomeDesc;
  final String startBtn;
  final String systemVersion;

  const OnboardingStrings({
    required this.welcomeTitle,
    required this.welcomeDesc,
    required this.startBtn,
    required this.systemVersion,
  });

  static const ru = OnboardingStrings(
    welcomeTitle: 'Добро пожаловать',
    welcomeDesc:
        'Glider Flight Core — профессиональная система управления и телеметрии для вашего планера.',
    startBtn: 'Начать работу',
    systemVersion: 'ВЕРСИЯ СИСТЕМЫ 1.2.0',
  );
}
