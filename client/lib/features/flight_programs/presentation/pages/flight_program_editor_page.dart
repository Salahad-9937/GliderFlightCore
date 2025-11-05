import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/flight_program.dart';
import '../../domain/entities/flight_program_step.dart';
import '../providers/flight_programs_providers.dart';
import '../providers/program_id_provider.dart';

/// Экран для редактирования полетной программы.
class FlightProgramEditorPage extends ConsumerWidget {
  final String profileId;
  final String programId;

  const FlightProgramEditorPage({
    super.key,
    required this.profileId,
    required this.programId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Используем новый провайдер для получения данных программы
    final programIdObj = ProgramId(profileId: profileId, programId: programId);
    final program = ref.watch(programByIdProvider(programIdObj));

    // Обрабатываем случай, когда программа не найдена
    if (program == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Программа не найдена')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(program.name),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Реализовать сохранение
            },
            icon: const Icon(Icons.save_outlined),
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: Column(
        children: [
          // TODO: Добавить поле для редактирования имени
          Expanded(
            child: program.steps.isEmpty
                ? const _EmptySteps()
                : ListView.builder(
                    itemCount: program.steps.length,
                    itemBuilder: (context, index) {
                      final step = program.steps[index];
                      return _StepCard(step: step);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Реализовать добавление нового шага
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Карточка для отображения одного шага программы.
class _StepCard extends StatelessWidget {
  const _StepCard({required this.step});
  final FlightProgramStep step;

  @override
  Widget build(BuildContext context) {
    final directionText = step.direction == 1 ? 'По часовой' : 'Против часовой';
    final icon = step.direction == 1
        ? Icons.rotate_right_rounded
        : Icons.rotate_left_rounded;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(icon),
        title: Text('Время: ${step.time} c'),
        subtitle: Text('Длительность: ${step.duration} мс'),
        trailing: Text(directionText),
      ),
    );
  }
}

/// Виджет для отображения пустого состояния, когда нет шагов.
class _EmptySteps extends StatelessWidget {
  const _EmptySteps();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_add_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            'Нет добавленных шагов',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите "+", чтобы добавить первый шаг',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}