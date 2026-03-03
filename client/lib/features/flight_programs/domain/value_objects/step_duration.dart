import 'package:flutter/foundation.dart';

/// Значение длительности шага (0-60 мин).
@immutable
class StepDuration {
  final int totalMs;

  static const int maxMs = 3600000; // 60 минут

  const StepDuration(int ms) : totalMs = ms < 0 ? 0 : (ms > maxMs ? maxMs : ms);

  factory StepDuration.fromComponents({int min = 0, int sec = 0, int ms = 0}) {
    return StepDuration((min * 60000) + (sec * 1000) + ms);
  }

  int get minutes => totalMs ~/ 60000;
  int get secondsOnly => (totalMs ~/ 1000) % 60;
  int get millisOnly => totalMs % 1000;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepDuration &&
          runtimeType == other.runtimeType &&
          totalMs == other.totalMs;

  @override
  int get hashCode => totalMs.hashCode;
}
