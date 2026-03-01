import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../../core/presentation/widgets/instrument_value.dart';
import '../providers/device_connection_providers.dart';
import 'calibration_bottom_sheet.dart';

/// Виджет отображения телеметрии в стиле кокпита.
class TelemetryDashboard extends ConsumerWidget {
  const TelemetryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionNotifierProvider);
    final strings = ref.watch(l10nProvider);

    return InstrumentCard(
      label: strings.comm.telemetryTitle,
      borderColor: device.isHardwareOk ? AppColors.primary : AppColors.error,
      actions: [
        IconButton(
          onPressed: () =>
              ref.read(deviceConnectionNotifierProvider.notifier).disconnect(),
          icon: const Icon(
            Icons.power_settings_new,
            size: 18,
            color: AppColors.alert,
          ),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > 400;

          return Column(
            children: [
              if (!device.isHardwareOk) _buildHardwareError(strings),

              if (isLandscape)
                Row(
                  children: [
                    Expanded(flex: 2, child: _buildMainValue(device, strings)),
                    const VerticalDivider(color: AppColors.border),
                    Expanded(flex: 3, child: _buildSensorGrid(device, strings)),
                  ],
                )
              else
                Column(
                  children: [
                    _buildMainValue(device, strings),
                    const Divider(color: AppColors.border, height: 32),
                    _buildSensorGrid(device, strings),
                  ],
                ),

              const SizedBox(height: 20),
              _buildCalibrationButton(context, strings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainValue(dynamic device, dynamic strings) {
    final altColor = device.isStable ? AppColors.primary : AppColors.warning;
    return Column(
      children: [
        InstrumentValue(
          value: device.altitude?.toStringAsFixed(1) ?? '0.0',
          unit: strings.comm.altitudeUnit,
          valueStyle: AppTextStyles.telemetryValueLarge,
          color: altColor,
        ),
        if (device.isCalibrating)
          Text(
            strings.comm.calibratingProgress.toUpperCase(),
            style: AppTextStyles.instrumentLabel.copyWith(
              color: AppColors.warning,
            ),
          ),
      ],
    );
  }

  Widget _buildSensorGrid(dynamic device, dynamic strings) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _SensorItem(
          icon: Icons.thermostat,
          value: '${device.temperature?.toStringAsFixed(1) ?? '--'}',
          unit: '°C',
          label: strings.comm.temperature,
        ),
        _SensorItem(
          icon: Icons.speed,
          value: '${device.currentPressure?.toStringAsFixed(0) ?? '--'}',
          unit: 'Pa',
          label: strings.comm.pressure,
        ),
        _SensorItem(
          icon: Icons.bolt,
          value: '${device.vcc?.toStringAsFixed(2) ?? '--'}',
          unit: 'V',
          label: strings.comm.power,
          color: (device.vcc != null && device.vcc! < 3.3)
              ? AppColors.error
              : AppColors.success,
        ),
      ],
    );
  }

  Widget _buildHardwareError(dynamic strings) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(8),
      color: AppColors.error.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.warning, color: AppColors.error, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              strings.comm.sensorError,
              style: AppTextStyles.instrumentLabel.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationButton(BuildContext context, dynamic strings) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => const CalibrationBottomSheet(),
        ),
        icon: const Icon(Icons.tune, size: 18),
        label: Text(
          strings.comm.calibrationTitle.toUpperCase(),
          style: AppTextStyles.button,
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.borderBright),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class _SensorItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color? color;

  const _SensorItem({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? Colors.grey),
            const SizedBox(width: 4),
            InstrumentValue(value: value, unit: unit, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text(label.toUpperCase(), style: AppTextStyles.instrumentLabel),
      ],
    );
  }
}
