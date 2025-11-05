import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/glider_profile.dart';
import '../providers/glider_profiles_providers.dart';

/// Показывает диалог для подтверждения удаления профиля планера.
void showDeleteProfileDialog(BuildContext context, WidgetRef ref, GliderProfile profile) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Подтверждение'),
        content: Text('Вы уверены, что хотите удалить профиль "${profile.name}"? Это действие необратимо.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          // Используем кнопку с акцентом на удаление
          FilledButton.tonal(
            onPressed: () {
              // Вызываем метод удаления из notifier
              ref.read(gliderProfilesNotifierProvider.notifier).deleteProfile(profile.id);
              Navigator.of(context).pop();
              
              // Показываем уведомление об успешном удалении
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Профиль "${profile.name}" удален')),
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