import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.error, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      title: Text(
        strings.core.confirmation.toUpperCase(),
        style: AppTextStyles.sectionTitle.copyWith(color: AppColors.error),
      ),
      content: Text(
        '${strings.profiles.deleteProfileConfirm.toUpperCase()}\n"${profile.name.toUpperCase()}"?',
        style: AppTextStyles.instrumentLabel.copyWith(
          color: Colors.white,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            strings.core.cancel.toUpperCase(),
            style: AppTextStyles.instrumentLabel,
          ),
        ),
        FilledButton(
          onPressed: () {
            // Обновлено имя провайдера
            ref.read(gliderProfilesProvider.notifier).deleteProfile(profile.id);
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          child: Text(
            strings.core.delete.toUpperCase(),
            style: AppTextStyles.button,
          ),
        ),
      ],
    ),
  );
}
