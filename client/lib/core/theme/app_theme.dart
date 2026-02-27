import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Конфигурация визуальной темы приложения.
///
/// Исправлена ошибка типизации CardThemeData и настроены локальные шрифты.
class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Установка основного шрифта для всего приложения
    fontFamily: 'Inter',

    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,

    // Использование CardThemeData вместо CardTheme
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      centerTitle: true,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),

    // Настройка базового TextTheme
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
      titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
      bodyMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
      labelSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w400),
    ),
  );
}
