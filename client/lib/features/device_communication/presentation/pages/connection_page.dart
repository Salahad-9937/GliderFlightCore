import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/flight_programs/domain/entities/flight_program.dart';
import '../../../../features/flight_programs/presentation/providers/flight_programs_providers.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../providers/device_connection_providers.dart';

/// Экран для управления подключением к устройству и его настройки.
class ConnectionPage extends ConsumerWidget {
  final String profileId;
  const ConnectionPage({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(flightProgramsProvider(profileId));
    final deviceState = ref.watch(deviceConnectionNotifierProvider);
    final notifier = ref.read(deviceConnectionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Подключение к устройству')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
              '1. Включите планер.\n'
              '2. В настройках Wi-Fi на телефоне подключитесь к сети "Glider-Timer".\n'
                  '3. Вернитесь в приложение и нажмите кнопку ниже.',
              textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Кнопка для проверки подключения
            ElevatedButton.icon(
              onPressed: deviceState.status == DeviceStatus.connecting ? null : notifier.connect,
              icon: deviceState.status == DeviceStatus.connecting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.wifi_find_rounded),
              label: const Text('Проверить подключение'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 50)),
            ),
            const SizedBox(height: 16),

            // Отображение статуса
            _buildConnectionStatus(context, deviceState),
            const Spacer(), // Занимает все оставшееся место

            // Кнопка загрузки программы, активна только при подключении
            if (deviceState.status == DeviceStatus.connected)
              FilledButton.icon(
                onPressed: () async {
                  final programToUpload = await _showProgramSelectionDialog(
                    context,
                    programsAsync.value ?? [],
                  );

                  if (programToUpload != null && context.mounted) {
                    final success = await notifier.uploadProgram(programToUpload);
                    if(context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'Программа успешно загружена' : 'Ошибка загрузки')),
                    );
                    }
                  }
                },
                icon: const Icon(Icons.upload_file_rounded),
                label: const Text('Загрузить программу на планер'),
                style: FilledButton.styleFrom(minimumSize: const Size(0, 50)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionStatus(BuildContext context, Device deviceState) {
    if (deviceState.status == DeviceStatus.disconnected) {
      return const SizedBox.shrink(); // Ничего не показываем, если еще не подключались
    }
    return Center(
      child: Text(
        _getStatusText(deviceState),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: _getStatusColor(context, deviceState.status),
            ),
      ),
    );
  }

  String _getStatusText(Device device) {
    switch (device.status) {
      case DeviceStatus.connected: return 'Успешно подключено к ${device.ipAddress}';
      case DeviceStatus.connecting: return 'Поиск устройства...';
      case DeviceStatus.disconnected: return '';
      case DeviceStatus.error: return device.errorMessage ?? 'Неизвестная ошибка';
    }
  }

  Color _getStatusColor(BuildContext context, DeviceStatus status) {
    switch (status) {
      case DeviceStatus.connected: return Colors.green;
      case DeviceStatus.error: return Theme.of(context).colorScheme.error;
      default: return Colors.grey;
    }
  }

  Future<FlightProgram?> _showProgramSelectionDialog(
      BuildContext context, List<FlightProgram> programs) {
    return showDialog<FlightProgram>(
      context: context,
      builder: (context) {
        if (programs.isEmpty) {
          return const AlertDialog(
            title: Text('Нет программ'),
            content: Text('Сначала создайте хотя бы одну полетную программу.'),
          );
        }
        return SimpleDialog(
          title: const Text('Выберите программу для загрузки'),
          children: [
            for (final program in programs)
              SimpleDialogOption(
                onPressed: () => Navigator.of(context).pop(program),
                child: Text(program.name),
              ),
          ],
        );
      },
    );
  }
}