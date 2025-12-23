import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/glider_profiles_providers.dart';

/// Диалог для редактирования имени профиля.
void showEditProfileDialog(BuildContext context, WidgetRef ref, String profileId, String currentName) {
  final controller = TextEditingController(text: currentName);
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Переименовать планер'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Новое название'),
            validator: (value) => (value == null || value.trim().isEmpty) ? 'Название не может быть пустым' : null,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Отмена')),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                ref.read(gliderProfilesNotifierProvider.notifier).updateProfileName(profileId, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      );
    },
  );
}