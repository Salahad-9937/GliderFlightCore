import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../providers/device_connection_providers.dart';

/// Умная карточка устройства.
///
/// Если нет подключения: показывает инструкцию и кнопку "Подключить".
/// Если есть подключение: показывает телеметрию (высота, температура и т.д.).
class DeviceStatusCard extends ConsumerWidget {
  final String profileId;
  const DeviceStatusCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionNotifierProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: device.status == DeviceStatus.connected
              ? _buildTelemetryState(context, ref, device)
              : _buildDisconnectedState(context, ref, device),
        ),
      ),
    );
  }

  // --- СОСТОЯНИЕ: ПОДКЛЮЧЕНО (ТЕЛЕМЕТРИЯ) ---

  Widget _buildTelemetryState(BuildContext context, WidgetRef ref, Device device) {
    // Если Hardware Error (датчик отвалился)
    if (!device.isHardwareOk) {
      return Column(
        key: const ValueKey('error_state'),
        children: [
          _buildHeader(context, device),
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
    
    // Цвет высоты зависит от стабильности
    final altColor = device.isStable ? Colors.white : Colors.amberAccent;

    return Column(
      key: const ValueKey('telemetry_state'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, device),
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
                      fontSize: 64, // Очень крупно
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
      ],
    );
  }

  // --- СОСТОЯНИЕ: ОТКЛЮЧЕНО (ИНСТРУКЦИЯ) ---

  Widget _buildDisconnectedState(BuildContext context, WidgetRef ref, Device device) {
    final notifier = ref.read(deviceConnectionNotifierProvider.notifier);
    final isConnecting = device.status == DeviceStatus.connecting;

    return Column(
      key: const ValueKey('disconnected_state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Подключение', style: Theme.of(context).textTheme.titleLarge),
            if (device.status == DeviceStatus.error)
               Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          ],
        ),
        const SizedBox(height: 16),
        
        // Инструкция
        const Text(
          '1. Включите питание планера.\n'
          '2. Подключите телефон к Wi-Fi сети "Glider-Timer".',
          style: TextStyle(height: 1.5, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Кнопка подключения
        FilledButton.icon(
          onPressed: isConnecting ? null : notifier.connect,
          icon: isConnecting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
              : const Icon(Icons.wifi_find_rounded),
          label: Text(isConnecting ? 'Поиск устройства...' : 'Проверить подключение'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),

        // Текст ошибки, если есть
        if (device.status == DeviceStatus.error)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              device.errorMessage ?? 'Не удалось подключиться',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  // --- ОБЩИЕ ВИДЖЕТЫ ---

  Widget _buildHeader(BuildContext context, Device device) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.wifi, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Text(
              'Подключено',
              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        Text(
          device.ipAddress ?? '',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
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