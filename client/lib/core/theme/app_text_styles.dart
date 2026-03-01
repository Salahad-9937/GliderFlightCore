import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Система типографики, ориентированная на мгновенное считывание данных.
class AppTextStyles {
  static const String _fontFamily = 'Inter';
  static const String _dataFontFamily = 'RobotoMono';

  /// Огромные значения телеметрии (Высота)
  static const TextStyle telemetryValueLarge = TextStyle(
    fontFamily: _dataFontFamily,
    fontSize: 72,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: -3,
  );

  /// Средние значения (Температура, Давление)
  static const TextStyle telemetryValueMedium = TextStyle(
    fontFamily: _dataFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  /// Подписи к приборам (Label)
  static const TextStyle instrumentLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w800,
    color: Color(0xFF888888),
    letterSpacing: 1.2,
    height: 1.0,
  );

  /// Заголовки блоков
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w900,
    color: AppColors.primary,
    letterSpacing: 0.5,
  );

  /// Текст кнопок
  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}
