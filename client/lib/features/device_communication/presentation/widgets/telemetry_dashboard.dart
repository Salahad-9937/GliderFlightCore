import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';
import '../providers/device_connection_providers.dart';
import 'calibration_bottom_sheet.dart';

/// Виджет отображения телеметрии (высота, температура, давление, напряжение).
class TelemetryDashboard extends ConsumerWidget {
  const TelemetryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionNotifierProvider);
    final strings = ref.watch(l10nProvider);

    if (!device.isHardwareOk) {
      return Column(
        key: const ValueKey('error_state'),
        children: [
          _buildHeader(context, ref, strings),
          const SizedBox(height: 16),
          _buildHardwareErrorCard(context, strings),
        ],
      );
    }

    final altitude = device.altitude?.toStringAsFixed(1) ?? '--';
    final temp = device.temperature?.toStringAsFixed(1) ?? '--';
    final pressure = device.currentPressure?.toStringAsFixed(0) ?? '--';
    final vcc = device.vcc?.toStringAsFixed(2) ?? '--';
    final altColor = device.isStable ? Colors.white : AppColors.warning;

    return Column(
      key: const ValueKey('telemetry_state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, ref, strings),
        const SizedBox(height: 16),

        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    altitude,
                    // Моноширинный шрифт для стабильности цифр
                    style: AppTextStyles.telemetryValue.copyWith(
                      color: altColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.comm.altitudeUnit,
                    style: AppTextStyles.title.copyWith(
                      color: Colors.grey,
                      fontSize: 24,
                    ),
                  ),
                ],
              ),
              if (device.isCalibrating)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    strings.comm.calibratingProgress,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildInfoItem(
              context,
              Icons.thermostat,
              '$temp°C',
              strings.comm.temperature,
            ),
            _buildInfoItem(
              context,
              Icons.speed,
              '$pressure Pa',
              strings.comm.pressure,
            ),
            _buildInfoItem(
              context,
              Icons.bolt,
              '$vcc V',
              strings.comm.power,
              color: (device.vcc != null && device.vcc! < 3.0)
                  ? AppColors.error
                  : null,
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),

        OutlinedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const CalibrationBottomSheet(),
            );
          },
          icon: const Icon(Icons.settings_input_component),
          label: Text(
            strings.comm.calibrationTitle,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, AppStrings strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.sensors, color: AppColors.success, size: 20),
            const SizedBox(width: 8),
            Text(
              strings.comm.sensorsActive,
              style: AppTextStyles.body.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: () =>
              ref.read(deviceConnectionNotifierProvider.notifier).disconnect(),
          icon: const Icon(Icons.link_off_rounded),
          tooltip: strings.comm.disconnect,
        ),
      ],
    );
  }

  Widget _buildHardwareErrorCard(BuildContext context, AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(strings.comm.sensorError, style: AppTextStyles.body),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    IconData icon,
    String value,
    String label, {
    Color? color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color ?? Colors.grey),
            const SizedBox(width: 4),
            Text(
              value,
              // Моноширинный шрифт для малых цифр
              style: const TextStyle(
                fontFamily: 'RobotoMono',
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ).copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.telemetryLabel),
      ],
    );
  }
}
