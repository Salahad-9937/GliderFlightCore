import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_text_styles.dart';

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
            Text(strings.panel.flightHistory, style: AppTextStyles.title),
            TextButton.icon(
              onPressed: () {
                // Будущая реализация синхронизации
              },
              icon: const Icon(Icons.sync_rounded),
              label: Text(
                strings.panel.sync,
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.history_rounded, color: Colors.grey),
            title: Text(
              strings.panel.noFlightData,
              style: AppTextStyles.body.copyWith(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
