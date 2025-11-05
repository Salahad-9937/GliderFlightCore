import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/flight_program.dart';
import '../providers/flight_programs_providers.dart';

/// Показывает диалог для подтверждения удаления полетной программы.
void showDeleteProgramDialog(
  BuildContext context,
  WidgetRef ref,
  String profileId,
  FlightProgram program,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Подтверждение'),
        content: Text('Вы уверены, что хотите удалить программу "${program.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton.tonal(
            onPressed: () {
              // Вызываем метод контроллера для удаления
              ref
                  .read(flightProgramsControllerProvider)
                  .deleteProgram(profileId, program.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Программа "${program.name}" удалена')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            ),
            child: const Text('Удалить'),
          ),
        ],
      );
    },
  );
}