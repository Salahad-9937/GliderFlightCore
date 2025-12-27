import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device_status.dart';
import '../providers/device_connection_providers.dart';
import 'connection_instructions.dart';
import 'telemetry_dashboard.dart';

/// Умная карточка устройства.
///
/// Выступает в роли "Оркестратора": следит за статусом подключения
/// и выбирает, какой интерфейс показать пользователю.
class DeviceStatusCard extends ConsumerWidget {
  final String profileId;
  const DeviceStatusCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionNotifierProvider);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          // Переключаемся между "Приборной панелью" и "Инструкцией"
          child: device.status == DeviceStatus.connected
              ? const TelemetryDashboard()
              : const ConnectionInstructions(),
        ),
      ),
    );
  }
}