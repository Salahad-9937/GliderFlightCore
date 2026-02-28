import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/system_health.dart';
import '../providers/system_health_provider.dart';

/// Виджет отображения системных метрик устройства.
class SystemHealthCard extends ConsumerWidget {
  final String profileId;
  const SystemHealthCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemAsync = ref.watch(systemHealthProvider(profileId));
    final strings = ref.watch(l10nProvider);
    ref.watch(systemUpdateTimerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, systemAsync.value, strings),
            const Divider(height: 24),
            systemAsync.when(
              data: (health) => health == null
                  ? Text(
                      strings.panel.deviceNotReady,
                      style: AppTextStyles.body,
                    )
                  : _buildSystemInfo(context, health, strings),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: LinearProgressIndicator(),
                ),
              ),
              error: (e, __) => Text(
                '${strings.panel.diagError}: $e',
                style: AppTextStyles.body.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    SystemHealth? health,
    AppStrings strings,
  ) {
    String timeAgo = '';
    if (health != null) {
      final diff = DateTime.now().difference(health.timestamp).inSeconds;
      timeAgo = diff < 60
          ? '$diff ${strings.panel.timeSecAgo}'
          : '${diff ~/ 60} ${strings.panel.timeMinAgo}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(strings.panel.systemDiagTitle, style: AppTextStyles.title),
        Row(
          children: [
            if (timeAgo.isNotEmpty)
              Text(timeAgo, style: AppTextStyles.telemetryLabel),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => ref.invalidate(systemHealthProvider(profileId)),
              icon: const Icon(Icons.refresh, size: 20),
              visualDensity: VisualDensity.compact,
              tooltip: strings.panel.refresh,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemInfo(
    BuildContext context,
    SystemHealth health,
    AppStrings strings,
  ) {
    final freeMemKb = (health.freeHeap / 1024).toStringAsFixed(1);
    final fsUsedMb = (health.fsUsed / 1024 / 1024).toStringAsFixed(2);
    final fsTotalMb = (health.fsTotal / 1024 / 1024).toStringAsFixed(2);

    final minutes = health.uptime ~/ 60;
    final seconds = health.uptime % 60;
    final uptimeString = minutes > 0
        ? '$minutes ${strings.panel.unitMin} $seconds ${strings.panel.unitSec}'
        : '$seconds ${strings.panel.unitSec}';

    return Column(
      children: [
        _buildRow(strings.panel.firmwareVersion, health.version),
        _buildRow(strings.panel.uptime, uptimeString),
        _buildRow(strings.panel.freeRam, '$freeMemKb KB'),
        _buildRow(strings.panel.fsMemory, '$fsUsedMb / $fsTotalMb MB'),
        _buildRow(strings.panel.chipId, health.chipId.toUpperCase()),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.telemetryLabel),
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontWeight: FontWeight.w600,
              fontFamily: 'RobotoMono',
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
