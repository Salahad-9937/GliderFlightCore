import 'package:flutter/material.dart';

/// Карточка для отображения статуса подключения к устройству.
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
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.grey,
                ),
                const SizedBox(width: 12),
                // Оборачиваем текст в Expanded, чтобы он занимал
                // оставшееся место и мог переноситься на новую строку.
                const Expanded(
                  child: Text(
                    'Нет подключения',
                    style: TextStyle(fontSize: 16), // Явно зададим размер для консистентности
                  ),
                ),
                // Spacer здесь больше не нужен, так как Expanded
                // уже отодвигает кнопку вправо.
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Реализовать переход на экран подключения
                  },
                  icon: const Icon(Icons.settings_bluetooth_rounded, size: 20),
                  label: const Text('Подключить'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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