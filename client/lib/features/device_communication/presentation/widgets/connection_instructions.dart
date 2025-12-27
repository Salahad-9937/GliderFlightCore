import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/device_status.dart';
import '../providers/device_connection_providers.dart';

/// Виджет с инструкцией по подключению.
///
/// Ответственность:
/// - Показать пошаговую инструкцию.
/// - Предоставить кнопку "Подключить".
/// - Отобразить ошибку подключения, если она возникла.
class ConnectionInstructions extends ConsumerWidget {
  const ConnectionInstructions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = ref.watch(deviceConnectionNotifierProvider);
    final notifier = ref.read(deviceConnectionNotifierProvider.notifier);
    final isConnecting = device.status == DeviceStatus.connecting;

    return Column(
      key: const ValueKey('disconnected_state'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Подключение', style: Theme.of(context).textTheme.titleLarge),
            if (device.status == DeviceStatus.error)
               Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          ],
        ),
        const SizedBox(height: 16),
        
        // Инструкция
        const Text(
          '1. Включите питание планера.\n'
          '2. Подключите телефон к Wi-Fi сети "Glider-Timer".',
          style: TextStyle(height: 1.5, color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Кнопка подключения
        FilledButton.icon(
          onPressed: isConnecting ? null : notifier.connect,
          icon: isConnecting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70))
              : const Icon(Icons.wifi_find_rounded),
          label: Text(isConnecting ? 'Поиск устройства...' : 'Проверить подключение'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),

        // Текст ошибки, если есть
        if (device.status == DeviceStatus.error)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Text(
              device.errorMessage ?? 'Не удалось подключиться',
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