import 'dart:math' as math;
import 'package:flutter/foundation.dart';

/// Значение угла сервопривода (0-180).
@immutable
class ServoAngle {
  final int value;

  static const int min = 0;
  static const int max = 180;

  const ServoAngle(int val) : value = val < min ? min : (val > max ? max : val);

  /// Преобразует угол в радианы для отрисовки (вынос логики из UI).
  double get radians => (value - 90) * math.pi / 180;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServoAngle &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value.toString();
}
