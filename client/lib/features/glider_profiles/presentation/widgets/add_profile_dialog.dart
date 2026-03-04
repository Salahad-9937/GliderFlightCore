import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/glider_profiles_providers.dart';

void showAddProfileDialog(BuildContext context, WidgetRef ref) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final strings = ref.read(l10nProvider);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primary, width: 1),
        borderRadius: BorderRadius.zero,
      ),
      title: Text(
        strings.profiles.newGliderProfile.toUpperCase(),
        style: AppTextStyles.sectionTitle,
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.telemetryValueMedium.copyWith(fontSize: 18),
          decoration: InputDecoration(
            labelText: strings.profiles.gliderName.toUpperCase(),
            labelStyle: AppTextStyles.instrumentLabel,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
            errorStyle: AppTextStyles.instrumentLabel.copyWith(
              color: AppColors.error,
              fontSize: 9,
            ),
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? strings.profiles.nameNotEmpty.toUpperCase()
              : null,
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
            if (formKey.currentState!.validate()) {
              // Обновлено имя провайдера
              ref
                  .read(gliderProfilesProvider.notifier)
                  .addProfile(controller.text.trim());
              Navigator.pop(context);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          child: Text(
            strings.core.ok.toUpperCase(),
            style: AppTextStyles.button,
          ),
        ),
      ],
    ),
  );
}
