import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../../core/presentation/widgets/instrument_value.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/device.dart';
import '../providers/device_connection_providers.dart';
import 'device_dialogs.dart';
import 'sensor_grid_item.dart';

/// Виджет отображения телеметрии в стиле кокпита.
class TelemetryDashboard extends ConsumerWidget {
  const TelemetryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionProvider);
    final strings = ref.watch(l10nProvider);

    return InstrumentCard(
      label: strings.comm.telemetryTitle,
      borderColor: device.isHardwareOk ? AppColors.primary : AppColors.error,
      actions: [
        IconButton(
          onPressed: () =>
              ref.read(deviceConnectionProvider.notifier).disconnect(),
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
              _buildMainLayout(device, strings, isLandscape),
              const SizedBox(height: 20),
              _buildCalibrationButton(context, strings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainLayout(Device device, AppStrings strings, bool isLandscape) {
    if (isLandscape) {
      return Row(
        children: [
          Expanded(flex: 2, child: _buildMainValue(device, strings)),
          const VerticalDivider(color: AppColors.border),
          Expanded(flex: 3, child: _buildSensorGrid(device, strings)),
        ],
      );
    }
    return Column(
      children: [
        _buildMainValue(device, strings),
        const Divider(color: AppColors.border, height: 32),
        _buildSensorGrid(device, strings),
      ],
    );
  }

  Widget _buildMainValue(Device device, AppStrings strings) {
    final altColor = device.isStable ? AppColors.primary : AppColors.warning;
    return Column(
      children: [
        RepaintBoundary(
          child: InstrumentValue(
            value: device.formattedAltitude,
            unit: strings.comm.altitudeUnit.t,
            valueStyle: AppTextStyles.telemetryValueLarge,
            color: altColor,
          ),
        ),
        if (device.isCalibrating)
          Text(
            strings.comm.calibratingProgress.t,
            style: AppTextStyles.instrumentLabel.copyWith(
              color: AppColors.warning,
            ),
          ),
      ],
    );
  }

  Widget _buildSensorGrid(Device device, AppStrings strings) {
    return Wrap(
      spacing: 24,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        SensorGridItem(
          icon: Icons.thermostat,
          value: device.formattedTemperature,
          unit: '°C',
          label: strings.comm.temperature,
        ),
        SensorGridItem(
          icon: Icons.speed,
          value: device.formattedPressure,
          unit: 'Pa',
          label: strings.comm.pressure,
        ),
        SensorGridItem(
          icon: Icons.bolt,
          value: device.formattedVcc,
          unit: 'V',
          label: strings.comm.power,
          color: device.isVccCritical ? AppColors.error : AppColors.success,
        ),
      ],
    );
  }

  Widget _buildHardwareError(AppStrings strings) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(8),
    color: AppColors.error.withValues(alpha: 0.1),
    child: Row(
      children: [
        const Icon(Icons.warning, color: AppColors.error, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            strings.comm.sensorError.t,
            style: AppTextStyles.instrumentLabel.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildCalibrationButton(BuildContext context, AppStrings strings) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => DeviceDialogs.showCalibration(context),
          icon: const Icon(Icons.tune, size: 18),
          label: Text(
            strings.comm.calibrationTitle.t,
            style: AppTextStyles.button,
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.borderBright),
            foregroundColor: Colors.white,
          ),
        ),
      );
}
