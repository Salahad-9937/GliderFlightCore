import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../../core/utils/string_extensions.dart';
import '../providers/system_health_provider.dart';

/// Виджет системных метрик в стиле терминала.
class SystemHealthCard extends ConsumerWidget {
  final String profileId;
  const SystemHealthCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemAsync = ref.watch(systemHealthProvider(profileId));
    final strings = ref.watch(l10nProvider);

    return InstrumentCard(
      label: strings.panel.systemDiagTitle,
      actions: [
        IconButton(
          onPressed: () => ref.invalidate(systemHealthProvider(profileId)),
          icon: const Icon(Icons.refresh, size: 16, color: AppColors.primary),
          visualDensity: VisualDensity.compact,
        ),
      ],
      child: systemAsync.when(
        data: (health) => health == null
            ? Text(
                strings.panel.deviceNotReady.t,
                style: AppTextStyles.instrumentLabel,
              )
            : Column(
                children: [
                  _row(strings.panel.firmwareVersion, health.version),
                  // Использование Consumer для изоляции ежесекундного обновления (Stage 14.4)
                  Consumer(
                    builder: (context, ref, _) {
                      ref.watch(systemUpdateTimerProvider);
                      return _row(
                        strings.panel.uptime,
                        health.formatUptime(
                          strings.panel.unitMin,
                          strings.panel.unitSec,
                        ),
                      );
                    },
                  ),
                  _row(strings.panel.freeRam, health.freeHeapLabel),
                  _row(strings.panel.fsMemory, health.fsMemoryLabel),
                  _row(strings.panel.chipId, health.chipId.t),
                ],
              ),
        loading: () => const LinearProgressIndicator(
          minHeight: 2,
          backgroundColor: Colors.transparent,
        ),
        error: (e, _) => Text(
          'DIAG_ERR: $e'.t,
          style: AppTextStyles.instrumentLabel.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.t, style: AppTextStyles.instrumentLabel),
        Text(
          value,
          style: AppTextStyles.telemetryValueMedium.copyWith(
            fontSize: 13,
            color: AppColors.primary,
          ),
        ),
      ],
    ),
  );
}
