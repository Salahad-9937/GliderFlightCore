import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../providers/device_connection_providers.dart';

/// Экран для управления подключением к устройству.
class ConnectionPage extends ConsumerWidget {
  final String profileId;
  const ConnectionPage({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceState = ref.watch(deviceConnectionNotifierProvider);
    final notifier = ref.read(deviceConnectionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Подключение к устройству')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  '1. Включите планер.\n'
                  '2. В настройках Wi-Fi на телефоне подключитесь к сети "Glider-Timer".\n'
                  '3. Вернитесь в приложение и нажмите кнопку ниже.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: deviceState.status == DeviceStatus.connecting ? null : notifier.connect,
              icon: deviceState.status == DeviceStatus.connecting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.wifi_find_rounded),
              label: const Text('Проверить подключение'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
            ),
            const SizedBox(height: 16),

            _buildConnectionStatus(context, deviceState),
            
            // Кнопка загрузки удалена отсюда и перенесена в список программ
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, Device deviceState) {
    if (deviceState.status == DeviceStatus.disconnected) {
      return const SizedBox.shrink();
    }
    return Center(
      child: Text(
        _getStatusText(deviceState),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _getStatusColor(context, deviceState.status),
            ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getStatusText(Device device) {
    switch (device.status) {
      case DeviceStatus.connected: return 'Успешно подключено к ${device.ipAddress}';
      case DeviceStatus.connecting: return 'Поиск устройства...';
      case DeviceStatus.disconnected: return '';
      case DeviceStatus.error: return device.errorMessage ?? 'Неизвестная ошибка';
    }
  }

  Color _getStatusColor(BuildContext context, DeviceStatus status) {
    switch (status) {
      case DeviceStatus.connected: return Colors.green;
      case DeviceStatus.error: return Theme.of(context).colorScheme.error;
      default: return Colors.grey;
    }
  }
}