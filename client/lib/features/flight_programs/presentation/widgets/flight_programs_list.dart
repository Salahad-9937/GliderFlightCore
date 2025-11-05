import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/flight_programs_providers.dart';

/// Виджет, отображающий список полетных программ для данного профиля.
class FlightProgramsList extends ConsumerWidget {
  final String profileId;
  const FlightProgramsList({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. СЛУШАЕМ `FutureProvider` для отображения данных
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
                // 2. ИСПОЛЬЗУЕМ `flightProgramsControllerProvider` для вызова метода
                ref
                    .read(flightProgramsControllerProvider)
                    .addProgram(profileId, 'Новая программа');
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
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(program.name),
                      // TODO: Добавить удаление через меню
                      trailing: const Icon(Icons.edit_note_rounded),
                      onTap: () {
                        // TODO: Перейти на экран редактирования программы
                      },
                    ),
                  ),
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