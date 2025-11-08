import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../pages/connection_page.dart';
import '../providers/device_connection_providers.dart';

/// Карточка, отображающая актуальный статус подключения к устройству.
class DeviceStatusCard extends ConsumerWidget {
  final String profileId;
  const DeviceStatusCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Просто следим за состоянием
    final deviceState = ref.watch(deviceConnectionNotifierProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Устройство', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildStatusIcon(deviceState.status),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatusText(context, deviceState),
                ),
                // Одна кнопка, которая всегда ведет на экран настроек
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ConnectionPage(profileId: profileId),
                      ),
                    );
                  },
                  child: const Text('Настроить'),
                ),
              ],
            ),
            if (deviceState.status == DeviceStatus.error)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  deviceState.errorMessage ?? 'Неизвестная ошибка',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.connected:
        return const Icon(Icons.wifi_channel_rounded, color: Colors.green);
      // Убираем connecting, так как он будет на другом экране
      case DeviceStatus.connecting:
      case DeviceStatus.disconnected:
        return const Icon(Icons.wifi_off_rounded, color: Colors.grey);
      case DeviceStatus.error:
        return const Icon(Icons.error_outline_rounded, color: Colors.red);
    }
  }

  Widget _buildStatusText(BuildContext context, Device device) {
    final style = Theme.of(context).textTheme.bodyLarge;
    switch (device.status) {
      case DeviceStatus.connected:
        return Text('Подключено (${device.ipAddress})', style: style);
      case DeviceStatus.connecting:
        return Text('Подключение...', style: style?.copyWith(color: Colors.grey));
      case DeviceStatus.disconnected:
        return Text('Нет подключения', style: style);
      case DeviceStatus.error:
        return Text('Ошибка подключения', style: style);
    }
  }
}