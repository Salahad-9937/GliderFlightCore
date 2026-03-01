import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../providers/system_health_provider.dart';

/// Виджет системных метрик в стиле терминала.
class SystemHealthCard extends ConsumerWidget {
  final String profileId;
  const SystemHealthCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemAsync = ref.watch(systemHealthProvider(profileId));
    final strings = ref.watch(l10nProvider);
    ref.watch(systemUpdateTimerProvider);

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
                strings.panel.deviceNotReady.toUpperCase(),
                style: AppTextStyles.instrumentLabel,
              )
            : Column(
                children: [
                  _buildRow(strings.panel.firmwareVersion, health.version),
                  _buildRow(
                    strings.panel.uptime,
                    _formatUptime(health.uptime, strings),
                  ),
                  _buildRow(
                    strings.panel.freeRam,
                    '${(health.freeHeap / 1024).toStringAsFixed(1)} KB',
                  ),
                  _buildRow(
                    strings.panel.fsMemory,
                    '${(health.fsUsed / 1024).toStringAsFixed(0)} / ${(health.fsTotal / 1024).toStringAsFixed(0)} KB',
                  ),
                  _buildRow(strings.panel.chipId, health.chipId.toUpperCase()),
                ],
              ),
        loading: () => const LinearProgressIndicator(
          minHeight: 2,
          backgroundColor: Colors.transparent,
        ),
        error: (e, _) => Text(
          'DIAG_ERR: $e',
          style: AppTextStyles.instrumentLabel.copyWith(color: AppColors.error),
        ),
      ),
    );
  }

  String _formatUptime(int seconds, dynamic strings) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0
        ? '$m ${strings.panel.unitMin} $s ${strings.panel.unitSec}'
        : '$s ${strings.panel.unitSec}';
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.instrumentLabel),
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
}
