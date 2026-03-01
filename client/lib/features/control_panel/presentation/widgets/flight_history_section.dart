import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';

/// Секция истории полетов в инструментальном стиле.
class FlightHistorySection extends ConsumerWidget {
  const FlightHistorySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);

    return InstrumentCard(
      label: strings.panel.flightHistory,
      actions: [
        TextButton.icon(
          onPressed: () {}, // Будущая реализация
          icon: const Icon(Icons.sync, size: 14, color: AppColors.primary),
          label: Text(
            strings.panel.sync.toUpperCase(),
            style: AppTextStyles.instrumentLabel.copyWith(
              color: AppColors.primary,
            ),
          ),
          style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            const Icon(
              Icons.history_toggle_off,
              color: AppColors.borderBright,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              strings.panel.noFlightData.toUpperCase(),
              style: AppTextStyles.instrumentLabel.copyWith(
                color: AppColors.borderBright,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
