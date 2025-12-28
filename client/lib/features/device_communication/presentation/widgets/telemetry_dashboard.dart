import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device.dart';
import '../providers/device_connection_providers.dart';
import 'calibration_bottom_sheet.dart';

/// Виджет отображения телеметрии (высота, температура, давление).
class TelemetryDashboard extends ConsumerWidget {
  const TelemetryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionNotifierProvider);

    // Если Hardware Error (датчик отвалился)
    if (!device.isHardwareOk) {
      return Column(
        key: const ValueKey('error_state'),
        children: [
          _buildHeader(context, ref, device),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 12),
                const Expanded(child: Text('Ошибка датчика BMP180! Проверьте подключение.')),
              ],
            ),
          ),
        ],
      );
    }

    final altitude = device.altitude?.toStringAsFixed(1) ?? '--';
    final temp = device.temperature?.toStringAsFixed(1) ?? '--';
    final pressure = device.currentPressure?.toStringAsFixed(0) ?? '--';
    
    final altColor = device.isStable ? Colors.white : Colors.amberAccent;

    return Column(
      key: const ValueKey('telemetry_state'),
      crossAxisAlignment: CrossAxisAlignment.stretch, // Растягиваем по ширине
      children: [
        _buildHeader(context, ref, device),
        const SizedBox(height: 8),
        
        // Крупная высота
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
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: altColor,
                      fontSize: 64, 
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'м',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (device.isCalibrating)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                      const SizedBox(width: 8),
                      const Text('Калибровка...', style: TextStyle(color: Colors.orangeAccent)),
                    ],
                  ),
                ),
            ],
          ),
        ),
           
        const SizedBox(height: 24),
        
        // Второстепенные данные
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoItem(context, Icons.thermostat, '$temp°C', 'Температура'),
            _buildInfoItem(context, Icons.speed, '$pressure Pa', 'Давление'),
          ],
        ),

        const SizedBox(height: 24),

        // Кнопка калибровки
        OutlinedButton.icon(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => const CalibrationBottomSheet(),
            );
          },
          icon: const Icon(Icons.settings_input_component),
          label: const Text('Калибровка датчиков'),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, Device device) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.wifi, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Подключено',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Row(
          children: [
            Text(
              device.ipAddress ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                ref.read(deviceConnectionNotifierProvider.notifier).disconnect();
              },
              icon: const Icon(Icons.link_off_rounded),
              tooltip: 'Отключиться',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value, String label) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.grey),
            const SizedBox(width: 6),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}