import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/system_health_provider.dart';
import '../../domain/entities/system_health.dart';

class SystemHealthCard extends ConsumerWidget {
  final String profileId;
  const SystemHealthCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemAsync = ref.watch(systemHealthProvider(profileId));
    // Таймер для обновления текста времени
    ref.watch(systemUpdateTimerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, systemAsync.value),
            const Divider(height: 24),
            systemAsync.when(
              data: (health) => health == null 
                ? const Text('Устройство не готово') 
                : _buildSystemInfo(context, health),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: LinearProgressIndicator(),
                ),
              ),
              error: (e, __) => Text('Ошибка диагностики: $e', 
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, SystemHealth? health) {
    String timeAgo = '';
    if (health != null) {
      final diff = DateTime.now().difference(health.timestamp).inSeconds;
      timeAgo = diff < 60 ? '$diff сек. назад' : '${diff ~/ 60} мин. назад';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Диагностика системы', style: Theme.of(context).textTheme.titleMedium),
        Row(
          children: [
            if (timeAgo.isNotEmpty)
              Text(timeAgo, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () => ref.invalidate(systemHealthProvider(profileId)),
              icon: const Icon(Icons.refresh, size: 20),
              visualDensity: VisualDensity.compact,
              tooltip: 'Обновить',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSystemInfo(BuildContext context, SystemHealth health) {
    final freeMemKb = (health.freeHeap / 1024).toStringAsFixed(1);
    final fsUsedMb = (health.fsUsed / 1024 / 1024).toStringAsFixed(2);
    final fsTotalMb = (health.fsTotal / 1024 / 1024).toStringAsFixed(2);

    // Форматирование Uptime
    final minutes = health.uptime ~/ 60;
    final seconds = health.uptime % 60;
    final uptimeString = minutes > 0 ? '$minutes мин. $seconds сек.' : '$seconds сек.';

    return Column(
      children: [
        _buildRow('Версия ПО', health.version),
        _buildRow('Uptime', uptimeString),
        _buildRow('Свободно RAM', '$freeMemKb KB'),
        _buildRow('Память FS', '$fsUsedMb / $fsTotalMb MB'),
        _buildRow('Chip ID', health.chipId.toUpperCase()),
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
        ],
      ),
    );
  }
}