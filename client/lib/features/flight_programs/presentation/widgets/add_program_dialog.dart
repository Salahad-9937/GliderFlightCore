import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
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
      title: Text(strings.newProgram),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: strings.programName),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? strings.nameEmptyError : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
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
          child: Text(strings.ok),
        ),
      ],
    ),
  );
}
