import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/flight_programs_providers.dart';

void showAddProgramDialog(
  BuildContext context,
  WidgetRef ref,
  String profileId,
) {
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primary),
      ),
      title: Text('NEW MISSION PROGRAM', style: AppTextStyles.sectionTitle),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.telemetryValueMedium.copyWith(fontSize: 18),
          decoration: InputDecoration(
            labelText: 'PROGRAM NAME',
            labelStyle: AppTextStyles.instrumentLabel,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'NAME REQUIRED' : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCEL', style: AppTextStyles.instrumentLabel),
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
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          child: Text('CREATE', style: AppTextStyles.button),
        ),
      ],
    ),
  );
}
