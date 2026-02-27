import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../domain/entities/device_status.dart';
import '../providers/device_connection_providers.dart';

/// Виджет с инструкцией по подключению к Wi-Fi планера.
class ConnectionInstructions extends ConsumerWidget {
  const ConnectionInstructions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionNotifierProvider);
    final notifier = ref.read(deviceConnectionNotifierProvider.notifier);
    final strings = ref.watch(l10nProvider);

    final isConnecting = device.status == DeviceStatus.connecting;

    return Column(
      key: const ValueKey('disconnected_state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.comm.connectionTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (device.status == DeviceStatus.error)
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.error,
              ),
          ],
        ),
        const SizedBox(height: 16),

        Text(
          '${strings.comm.connectionStep1}\n${strings.comm.connectionStep2}',
          style: const TextStyle(height: 1.5, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        FilledButton.icon(
          onPressed: isConnecting ? null : notifier.connect,
          icon: isConnecting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white70,
                  ),
                )
              : const Icon(Icons.wifi_find_rounded),
          label: Text(
            isConnecting
                ? strings.comm.connectionSearching
                : strings.comm.connectionCheck,
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),

        if (device.status == DeviceStatus.error)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              device.errorMessage ?? strings.comm.connectionError,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
