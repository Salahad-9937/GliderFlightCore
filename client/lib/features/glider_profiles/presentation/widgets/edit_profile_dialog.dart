import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
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
      title: Text(strings.profiles.renameGlider),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: strings.profiles.gliderName),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? strings.profiles.nameNotEmpty
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.core.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              ref
                  .read(gliderProfilesNotifierProvider.notifier)
                  .updateProfileName(profileId, controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: Text(strings.core.save),
        ),
      ],
    ),
  );
}
