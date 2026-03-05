import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/presentation/widgets/tactical_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../providers/glider_profiles_providers.dart';

void showEditProfileDialog(
  BuildContext context,
  WidgetRef ref,
  String profileId,
  String currentName,
) {
  final controller = TextEditingController(text: currentName);
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
        strings.profiles.renameGlider.t,
        style: AppTextStyles.sectionTitle,
      ),
      content: Form(
        key: formKey,
        child: TacticalTextField(
          controller: controller,
          label: strings.profiles.gliderName,
          autofocus: true,
          validator: (v) =>
              Validators.notEmpty(v, strings.profiles.nameNotEmpty.t),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            strings.core.cancel.t,
            style: AppTextStyles.instrumentLabel,
          ),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              ref
                  .read(gliderProfilesProvider.notifier)
                  .updateProfileName(profileId, controller.text.trim());
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
          child: Text(strings.core.save.t, style: AppTextStyles.button),
        ),
      ],
    ),
  );
}
