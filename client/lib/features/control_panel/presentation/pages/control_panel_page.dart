import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../glider_profiles/glider_profiles.dart';
// Удаляем импорт старой заглушки
// import '../widgets/flight_programs_section.dart';
// Импортируем новый виджет из его фичи
import '../../../flight_programs/flight_programs.dart';

import '../widgets/device_status_card.dart';
import '../widgets/flight_history_section.dart';
// import '../widgets/flight_programs_section.dart';

/// Координирующий экран ("дэшборд") для управления конкретным планером.
class ControlPanelPage extends ConsumerWidget {
  final String gliderProfileId;
  const ControlPanelPage({super.key, required this.gliderProfileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileByIdProvider(gliderProfileId));

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Профиль не найден')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit_outlined))
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const DeviceStatusCard(),
          const SizedBox(height: 24),
          // Заменяем старую заглушку на новый виджет
          FlightProgramsList(profileId: gliderProfileId),
          const SizedBox(height: 24),
          const FlightHistorySection(),
        ],
      ),
    );
  }
}