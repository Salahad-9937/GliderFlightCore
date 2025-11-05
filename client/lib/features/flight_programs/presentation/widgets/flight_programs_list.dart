import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/flight_program.dart';
import '../pages/flight_program_editor_page.dart';
import '../providers/flight_programs_providers.dart';
import 'add_program_dialog.dart';
import 'delete_program_dialog.dart';

/// Виджет, отображающий список полетных программ для данного профиля.
class FlightProgramsList extends ConsumerWidget {
  final String profileId;
  const FlightProgramsList({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(flightProgramsProvider(profileId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Полетные программы', style: Theme.of(context).textTheme.titleLarge),
            IconButton(
              onPressed: () {
                showAddProgramDialog(context, ref, profileId);
              },
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Создать программу',
            )
          ],
        ),
        const SizedBox(height: 8),
        programsAsync.when(
          data: (programs) {
            if (programs.isEmpty) {
              return const Card(
                child: ListTile(
                  leading: Icon(Icons.playlist_add_check_circle_outlined),
                  title: Text('Нет созданных программ'),
                  subtitle: Text('Нажмите "+", чтобы добавить'),
                ),
              );
            }
            return Column(
              children: [
                for (final program in programs)
                  _FlightProgramCard(profileId: profileId, program: program),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(title: Text('Ошибка загрузки программ: $e')),
          ),
        )
      ],
    );
  }
}

/// Виджет-карточка для отображения одной полетной программы.
class _FlightProgramCard extends ConsumerWidget {
  const _FlightProgramCard({
    required this.profileId,
    required this.program,
  });

  final String profileId;
  final FlightProgram program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(program.name),
        subtitle: Text('Шагов: ${program.steps.length}'),
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => FlightProgramEditorPage(
              profileId: profileId,
              programId: program.id,
            ),
          ));
        },
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => FlightProgramEditorPage(
                  profileId: profileId,
                  programId: program.id,
                ),
              ));
            } else if (value == 'delete') {
              showDeleteProgramDialog(context, ref, profileId, program);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_note_rounded),
                title: Text('Редактировать'),
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Удалить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}