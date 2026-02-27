import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/l10n/app_strings.dart';
import '../providers/sensor_calibration_providers.dart';

/// Шторка (Bottom Sheet) для управления калибровкой датчиков.
class CalibrationBottomSheet extends ConsumerWidget {
  const CalibrationBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibState = ref.watch(sensorCalibrationProvider);
    final notifier = ref.read(sensorCalibrationProvider.notifier);
    final strings = ref.watch(l10nProvider);

    final isBusy =
        calibState.phase == CalibrationPhase.zeroing ||
        calibState.phase == CalibrationPhase.stabilization ||
        calibState.phase == CalibrationPhase.measuring;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.calibrationTitle,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            if (calibState.phase == CalibrationPhase.idle ||
                calibState.phase == CalibrationPhase.success) ...[
              Text(
                strings.operationalControl,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => notifier.zeroAltitude(),
                icon: const Icon(Icons.vertical_align_center),
                label: Text(strings.zeroAltitudeBtn),
              ),
              const SizedBox(height: 24),
            ],

            if (calibState.phase == CalibrationPhase.zeroing) ...[
              Text(
                strings.operationalControl,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildProgressIndicator(
                context,
                calibState,
                label: strings.zeroingProcess,
                color: Colors.lightBlue,
              ),
              const SizedBox(height: 16),
            ],

            if (calibState.phase != CalibrationPhase.zeroing) ...[
              Text(
                strings.fullSetup,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              if (calibState.phase == CalibrationPhase.idle)
                FilledButton.icon(
                  onPressed: notifier.startFullCalibration,
                  icon: const Icon(Icons.build_circle_outlined),
                  label: Text(strings.startFullCalibBtn),
                )
              else if (calibState.phase == CalibrationPhase.stabilization)
                _buildProgressIndicator(
                  context,
                  calibState,
                  label: strings.stabilizationProcess,
                  color: Colors.orange,
                )
              else if (calibState.phase == CalibrationPhase.measuring)
                _buildProgressIndicator(
                  context,
                  calibState,
                  label: strings.measuringProcess,
                  color: Colors.blue,
                )
              else if (calibState.phase == CalibrationPhase.success)
                _buildSuccessState(context, notifier, strings)
              else if (calibState.phase == CalibrationPhase.error)
                _buildErrorState(
                  context,
                  notifier,
                  calibState.errorMessage,
                  strings,
                ),
            ],

            if (isBusy) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: notifier.cancelOperation,
                icon: const Icon(Icons.cancel_outlined),
                label: Text(strings.cancelOperation),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
              ),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context,
    CalibrationState state, {
    required String label,
    required Color color,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: state.progress,
              color: color,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text('${(state.progress * 100).toInt()}%'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(
    BuildContext context,
    SensorCalibrationNotifier notifier,
    AppStrings strings,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 32),
            const SizedBox(width: 8),
            Text(
              strings.calibSuccess,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            notifier.saveCalibration();
            Navigator.pop(context);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(strings.calibSavedNotify)));
          },
          child: Text(strings.saveToMemoryBtn),
        ),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    SensorCalibrationNotifier notifier,
    String? error,
    AppStrings strings,
  ) {
    return Column(
      children: [
        Text(
          error ?? strings.error,
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: notifier.reset, child: Text(strings.retry)),
      ],
    );
  }
}
