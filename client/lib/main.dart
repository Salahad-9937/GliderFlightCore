import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/glider_profiles/presentation/pages/glider_profiles_page.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

/// Корневой виджет приложения.
///
/// Использует [AppTheme] для настройки визуального стиля и локальных шрифтов.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Glider Flight Core',
      debugShowCheckedModeBanner: false,

      // Применение профессиональной темы с локальными шрифтами
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,

      home: const GliderProfilesPage(),
    );
  }
}
