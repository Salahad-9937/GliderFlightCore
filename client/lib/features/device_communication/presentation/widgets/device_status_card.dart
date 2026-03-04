import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device_status.dart';
import '../providers/device_connection_providers.dart';
import 'connection_instructions.dart';
import 'telemetry_dashboard.dart';

/// Умная карточка устройства в инструментальном стиле.
class DeviceStatusCard extends ConsumerWidget {
  final String profileId;
  const DeviceStatusCard({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Обновлено имя провайдера
    final device = ref.watch(deviceConnectionProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOutQuart,
      child: device.status == DeviceStatus.connected
          ? const TelemetryDashboard()
          : const ConnectionInstructions(),
    );
  }
}
