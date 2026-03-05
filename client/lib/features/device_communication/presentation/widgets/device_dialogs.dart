import 'package:flutter/material.dart';
import 'calibration_bottom_sheet.dart';

/// Фабрика для вызова системных диалогов и шнорок устройства.
class DeviceDialogs {
  /// Показывает терминал калибровки датчиков.
  static void showCalibration(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CalibrationBottomSheet(),
    );
  }
}
