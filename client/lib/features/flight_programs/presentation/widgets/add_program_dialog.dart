import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/flight_programs_providers.dart';

/// Показывает диалоговое окно для добавления новой полетной программы.
void showAddProgramDialog(BuildContext context, WidgetRef ref, String profileId) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Новая программа полета'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Название программы'),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Название не может быть пустым';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Вызываем метод контроллера для добавления
                ref
                    .read(flightProgramsControllerProvider)
                    .addProgram(profileId, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Создать'),
          ),
        ],
      );
    },
  );
}