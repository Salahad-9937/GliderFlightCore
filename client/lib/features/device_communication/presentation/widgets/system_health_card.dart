import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../domain/entities/system_health.dart';
import '../providers/system_health_provider.dart';

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
                  ? Text(strings.deviceNotReady)
                  : _buildSystemInfo(context, health, strings),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: LinearProgressIndicator(),
                ),
              ),
              error: (e, __) => Text(
                '${strings.diagError}: $e',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
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
          ? '$diff ${strings.timeSecAgo}'
          : '${diff ~/ 60} ${strings.timeMinAgo}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          strings.systemDiagTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Row(
          children: [
            if (timeAgo.isNotEmpty)
              Text(
                timeAgo,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => ref.invalidate(systemHealthProvider(profileId)),
              icon: const Icon(Icons.refresh, size: 20),
              visualDensity: VisualDensity.compact,
              tooltip: strings.refresh,
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
        ? '$minutes ${strings.unitMin} $seconds ${strings.unitSec}'
        : '$seconds ${strings.unitSec}';

    return Column(
      children: [
        _buildRow(strings.firmwareVersion, health.version),
        _buildRow(strings.uptime, uptimeString),
        _buildRow(strings.freeRam, '$freeMemKb KB'),
        _buildRow(strings.fsMemory, '$fsUsedMb / $fsTotalMb MB'),
        _buildRow(strings.chipId, health.chipId.toUpperCase()),
      ],
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
