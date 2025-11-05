import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ИМПОРТ ИЗМЕНЕН: Теперь мы ссылаемся на публичный файл фичи,
// а не на ее внутреннюю структуру.
import '../../../glider_profiles/glider_profiles.dart';
import '../widgets/device_status_card.dart';
import '../widgets/flight_history_section.dart';
import '../widgets/flight_programs_section.dart';

/// Координирующий экран ("дэшборд") для управления конкретным планером.
class ControlPanelPage extends ConsumerWidget {
  /// ID профиля планера, которым мы управляем.
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
        children: const [
          // Блок 1: Статус устройства
          DeviceStatusCard(),
          SizedBox(height: 24),
          // Блок 2: Полетные программы
          FlightProgramsSection(),
          SizedBox(height: 24),
          // Блок 3: История полетов
          FlightHistorySection(),
        ],
      ),
    );
  }
}