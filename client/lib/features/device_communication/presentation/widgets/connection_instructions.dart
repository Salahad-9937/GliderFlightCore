import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../domain/entities/device_status.dart';
import '../providers/device_connection_providers.dart';

/// Виджет ожидания связи в стиле системного лога.
class ConnectionInstructions extends ConsumerWidget {
  const ConnectionInstructions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Обновлено имя провайдера на сгенерированное
    final device = ref.watch(deviceConnectionProvider);
    final notifier = ref.read(deviceConnectionProvider.notifier);
    final strings = ref.watch(l10nProvider);

    final isConnecting = device.status == DeviceStatus.connecting;
    final isError = device.status == DeviceStatus.error;

    return InstrumentCard(
      label: 'SYSTEM STATUS: OFFLINE',
      borderColor: isError ? AppColors.error : AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${strings.comm.connectionStep1}\n${strings.comm.connectionStep2}'
                .toUpperCase(),
            style: AppTextStyles.instrumentLabel.copyWith(height: 1.8),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: isConnecting ? null : notifier.connect,
            style: FilledButton.styleFrom(
              backgroundColor: isError ? AppColors.error : AppColors.primary,
              foregroundColor: Colors.black,
            ),
            child: isConnecting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : Text(
                    strings.comm.connectionCheck.toUpperCase(),
                    style: AppTextStyles.button,
                  ),
          ),
          if (isError)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'ERROR: ${device.errorMessage}'.toUpperCase(),
                style: AppTextStyles.instrumentLabel.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}
