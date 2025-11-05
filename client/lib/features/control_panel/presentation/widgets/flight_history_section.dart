import 'package:flutter/material.dart';

/// Секция для просмотра истории полетов.
///
/// ЗАГЛУШКА: В будущем будет заменен виджетом из фичи flight_history.
class FlightHistorySection extends StatelessWidget {
  const FlightHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('История полетов', style: Theme.of(context).textTheme.titleLarge),
            TextButton.icon(
              onPressed: () {
                // TODO: Реализовать синхронизацию с устройством
              },
              icon: const Icon(Icons.sync_rounded),
              label: const Text('Синхронизировать'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Card(
          child: ListTile(title: Text('Нет данных о полетах')),
        ),
      ],
    );
  }
}