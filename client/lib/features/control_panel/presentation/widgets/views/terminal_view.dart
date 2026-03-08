import 'package:flutter/material.dart';
import '../../../../device_communication/presentation/widgets/device_status_card.dart';
import '../../../../device_communication/presentation/widgets/system_health_card.dart';

/// Вкладка "Терминал": отображение телеметрии и здоровья системы.
class TerminalView extends StatelessWidget {
  final String profileId;
  const TerminalView({super.key, required this.profileId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      children: [
        DeviceStatusCard(profileId: profileId),
        const SizedBox(height: 16),
        SystemHealthCard(profileId: profileId),
      ],
    );
  }
}
