import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/glider_profiles_providers.dart';

/// Показывает диалоговое окно для добавления нового профиля планера.
void showAddProfileDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Новый профиль планера'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Название планера'),
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
                ref
                    .read(gliderProfilesNotifierProvider.notifier)
                    .addProfile(controller.text.trim());
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