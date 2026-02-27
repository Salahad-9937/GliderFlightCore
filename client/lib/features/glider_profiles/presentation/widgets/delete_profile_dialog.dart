import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../domain/entities/glider_profile.dart';
import '../providers/glider_profiles_providers.dart';

void showDeleteProfileDialog(
  BuildContext context,
  WidgetRef ref,
  GliderProfile profile,
) {
  final strings = ref.read(l10nProvider);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.core.confirmation),
      content: Text(
        '${strings.profiles.deleteProfileConfirm} "${profile.name}"?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.core.cancel),
        ),
        FilledButton.tonal(
          onPressed: () {
            ref
                .read(gliderProfilesNotifierProvider.notifier)
                .deleteProfile(profile.id);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(strings.profiles.profileDeleted)),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          child: Text(strings.core.delete),
        ),
      ],
    ),
  );
}
