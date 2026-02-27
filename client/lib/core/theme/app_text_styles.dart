import 'package:flutter/material.dart';

/// Профессиональная система типографики приложения.
///
/// Использует Inter для текстов и RobotoMono для телеметрии.
class AppTextStyles {
  static const String _fontFamily = 'Inter';
  static const String _dataFontFamily = 'RobotoMono';

  /// Стиль для крупных значений телеметрии (высота, давление).
  static const TextStyle telemetryValue = TextStyle(
    fontFamily: _dataFontFamily,
    fontSize: 64,
    fontWeight: FontWeight.w500,
    letterSpacing: -2,
  );

  /// Стиль для подписей к данным телеметрии.
  static const TextStyle telemetryLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
    letterSpacing: 0.5,
  );

  /// Стиль заголовков разделов.
  static const TextStyle title = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  /// Основной текст интерфейса.
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );
}
