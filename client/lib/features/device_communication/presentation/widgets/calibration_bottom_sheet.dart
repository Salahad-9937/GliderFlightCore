import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sensor_calibration_providers.dart';

/// Шторка (Bottom Sheet) для управления калибровкой датчиков.
class CalibrationBottomSheet extends ConsumerWidget {
  const CalibrationBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibState = ref.watch(sensorCalibrationProvider);
    final notifier = ref.read(sensorCalibrationProvider.notifier);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(24.0),
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Калибровка датчиков',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // --- БЛОК 1: БЫСТРОЕ ОБНУЛЕНИЕ ---
            // Показываем кнопку только если мы в покое или уже закончили что-то другое
            if (calibState.phase == CalibrationPhase.idle || calibState.phase == CalibrationPhase.success) ...[
              Text('Оперативное управление', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  // Ждем завершения операции
                  final success = await notifier.zeroAltitude();
                  // Если успешно и экран еще открыт - закрываем и показываем уведомление
                  if (success && context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Высота обнулена')),
                    );
                  }
                },
                icon: const Icon(Icons.vertical_align_center),
                label: const Text('Обнулить высоту (Zero)'),
              ),
              const SizedBox(height: 24),
            ],

            // --- БЛОК 2: ПРОГРЕСС БАРЫ ---
            // Если идет обнуление
            if (calibState.phase == CalibrationPhase.zeroing) ...[
               Text('Оперативное управление', style: Theme.of(context).textTheme.titleSmall),
               const SizedBox(height: 8),
               _buildProgressIndicator(
                 context, 
                 calibState, 
                 label: 'Обнуление высоты...', 
                 color: Colors.lightBlue
               ),
               const SizedBox(height: 24),
            ],

            // --- БЛОК 3: ПОЛНАЯ КАЛИБРОВКА ---
            Text('Полная настройка', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),

            if (calibState.phase == CalibrationPhase.idle || calibState.phase == CalibrationPhase.zeroing)
              // Если идет обнуление, блокируем кнопку полной калибровки
              FilledButton.icon(
                onPressed: calibState.phase == CalibrationPhase.zeroing ? null : notifier.startFullCalibration,
                icon: const Icon(Icons.build_circle_outlined),
                label: const Text('Запустить полную калибровку'),
              )
            else if (calibState.phase == CalibrationPhase.stabilization)
              _buildProgressIndicator(
                context, 
                calibState, 
                label: 'Термостабилизация...', 
                color: Colors.orange
              )
            else if (calibState.phase == CalibrationPhase.measuring)
              _buildProgressIndicator(
                context, 
                calibState, 
                label: 'Сбор данных и усреднение...', 
                color: Colors.blue
              )
            else if (calibState.phase == CalibrationPhase.success)
              _buildSuccessState(context, notifier)
            else if (calibState.phase == CalibrationPhase.error)
              _buildErrorState(context, notifier, calibState.errorMessage),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(
    BuildContext context, 
    CalibrationState state, 
    {required String label, required Color color}
  ) {
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

  Widget _buildSuccessState(BuildContext context, SensorCalibrationNotifier notifier) {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 8),
            Text('Калибровка завершена!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () {
            notifier.saveCalibration();
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Калибровка сохранена в память')),
            );
          },
          child: const Text('Сохранить в память'),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, SensorCalibrationNotifier notifier, String? error) {
    return Column(
      children: [
        Text(error ?? 'Ошибка', style: TextStyle(color: Theme.of(context).colorScheme.error)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: notifier.reset,
          child: const Text('Попробовать снова'),
        ),
      ],
    );
  }
}