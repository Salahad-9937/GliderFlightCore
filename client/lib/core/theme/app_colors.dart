import 'package:flutter/material.dart';

/// Тактическая палитра цветов для работы в полевых условиях.
/// Оптимизирована для высокой контрастности и OLED-экранов.
class AppColors {
  // Фон - глубокий черный для контраста на солнце
  static const background = Color(0xFF000000);
  static const surface = Color(0xFF121212);
  static const surfaceLight = Color(0xFF1E1E1E);

  // Основной акцент - авиационный голубой
  static const primary = Color(0xFF00E5FF);
  static const accent = Color(0xFF00B0FF);

  // Сигнальные цвета (Status Colors)
  static const success = Color(0xFF00E676); // Neon Green
  static const warning = Color(0xFFFFEA00); // Safety Yellow
  static const alert = Color(0xFFFF3D00); // Safety Orange
  static const error = Color(0xFFFF1744); // Bright Red

  // Цвета телеметрии
  static const vccOk = success;
  static const vccLow = warning;
  static const vccCritical = error;

  // Границы и разделители
  static const border = Color(0xFF333333);
  static const borderBright = Color(0xFF444444);
}
