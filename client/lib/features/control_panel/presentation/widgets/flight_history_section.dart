import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';

/// Секция для просмотра истории полетов.
///
/// На данный момент является заглушкой для будущей фичи flight_history.
class FlightHistorySection extends ConsumerWidget {
  const FlightHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.flightHistory,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton.icon(
              onPressed: () {
                // Будущая реализация синхронизации
              },
              icon: const Icon(Icons.sync_rounded),
              label: Text(strings.sync),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history_rounded, color: Colors.grey),
            title: Text(strings.noFlightData),
          ),
        ),
      ],
    );
  }
}
