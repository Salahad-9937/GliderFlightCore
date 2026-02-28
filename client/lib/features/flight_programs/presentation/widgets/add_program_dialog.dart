import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/flight_programs_providers.dart';

void showAddProgramDialog(
  BuildContext context,
  WidgetRef ref,
  String profileId,
) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final strings = ref.read(l10nProvider);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.prog.newProgram, style: AppTextStyles.title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            labelText: strings.prog.programName,
            labelStyle: AppTextStyles.telemetryLabel,
          ),
          validator: (v) => (v == null || v.trim().isEmpty)
              ? strings.prog.nameEmptyError
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.core.cancel, style: AppTextStyles.body),
        ),
        FilledButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              ref
                  .read(flightProgramsControllerProvider)
                  .addProgram(profileId, controller.text.trim());
              Navigator.pop(context);
            }
          },
          child: Text(
            strings.core.ok,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
