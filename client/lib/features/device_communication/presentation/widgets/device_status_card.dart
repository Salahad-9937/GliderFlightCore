import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../pages/connection_page.dart';
import '../providers/device_connection_providers.dart';

/// Карточка телеметрии и статуса устройства.
class DeviceStatusCard extends ConsumerWidget {
  final String profileId;
  const DeviceStatusCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionNotifierProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          // Переход к настройкам подключения при клике на карточку
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ConnectionPage(profileId: profileId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, device),
              const SizedBox(height: 16),
              if (device.status == DeviceStatus.connected)
                _buildTelemetry(context, device)
              else
                _buildDisconnectedState(context, device),
            ],
          ),
        ),
      ),
    );
  }

  /// Заголовок с иконкой статуса и IP
  Widget _buildHeader(BuildContext context, Device device) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (device.status) {
      case DeviceStatus.connected:
        statusColor = Colors.green;
        statusText = 'Подключено';
        statusIcon = Icons.wifi;
        break;
      case DeviceStatus.connecting:
        statusColor = Colors.orange;
        statusText = 'Подключение...';
        statusIcon = Icons.wifi_protected_setup;
        break;
      case DeviceStatus.error:
        statusColor = Colors.red;
        statusText = 'Ошибка связи';
        statusIcon = Icons.wifi_off;
        break;
      case DeviceStatus.disconnected:
      statusColor = Colors.grey;
        statusText = 'Нет подключения';
        statusIcon = Icons.wifi_off;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: 8),
            Text(
              statusText,
              style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        if (device.status == DeviceStatus.connected)
          Text(
            device.ipAddress ?? '',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
      ],
    );
  }

  /// Основной блок телеметрии (Высота, Температура)
  Widget _buildTelemetry(BuildContext context, Device device) {
    // Если Hardware Error
    if (!device.isHardwareOk) {
      return Container(
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
      );
    }

    final altitude = device.altitude?.toStringAsFixed(1) ?? '--';
    final temp = device.temperature?.toStringAsFixed(1) ?? '--';
    final pressure = device.currentPressure?.toStringAsFixed(0) ?? '--';
    
    // Цвет высоты зависит от стабильности
    final altColor = device.isStable ? Colors.white : Colors.amberAccent;

    return Column(
      children: [
        // Крупная высота
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
                 Text('Калибровка...', style: TextStyle(color: Colors.orangeAccent)),
               ],
             ),
           ),
           
        const SizedBox(height: 16),
        
        // Второстепенные данные
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildInfoItem(context, Icons.thermostat, '$temp°C', 'Темп.'),
            _buildInfoItem(context, Icons.speed, '$pressure Pa', 'Давление'),
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
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDisconnectedState(BuildContext context, Device device) {
    if (device.status == DeviceStatus.error) {
       return Text(
        device.errorMessage ?? 'Неизвестная ошибка',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    }
    return const Text(
      'Подключитесь к Wi-Fi планера и нажмите "Настроить", чтобы увидеть телеметрию.',
      style: TextStyle(color: Colors.grey),
    );
  }
}