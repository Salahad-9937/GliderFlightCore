import 'package:flutter/material.dart';

/// Карточка для отображения статуса подключения к устройству.
///
/// ЗАГЛУШКА: В будущем будет заменен виджетом из фичи device_communication.
class DeviceStatusCard extends StatelessWidget {
  const DeviceStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                Text(
                  'Нет подключения',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Реализовать переход на экран подключения
                  },
                  icon: const Icon(Icons.settings_bluetooth_rounded),
                  label: const Text('Подключить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}