import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/presentation/widgets/tactical_text_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/entities/flight_program.dart';
import '../providers/flight_programs_providers.dart';

/// Фабрика для вызова диалогов управления программами.
class FlightProgramDialogs {
  /// Диалог создания новой программы.
  static void showAdd(BuildContext context, WidgetRef ref, String profileId) {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final strings = ref.read(l10nProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.primary),
        ),
        title: Text(
          strings.prog.newMissionProgram.t,
          style: AppTextStyles.sectionTitle,
        ),
        content: Form(
          key: formKey,
          child: TacticalTextField(
            controller: controller,
            label: strings.prog.programName,
            autofocus: true,
            validator: (v) =>
                Validators.notEmpty(v, strings.prog.nameEmptyError.t),
          ),
        ),
        actions: [
          _cancelButton(context, strings),
          _confirmButton(strings.core.ok, () {
            if (formKey.currentState!.validate()) {
              ref
                  .read(flightProgramsProvider(profileId).notifier)
                  .addProgram(controller.text.trim());
              Navigator.pop(context);
            }
          }),
        ],
      ),
    );
  }

  /// Диалог подтверждения удаления программы.
  static void showDelete(
    BuildContext context,
    WidgetRef ref,
    String profileId,
    FlightProgram program,
  ) {
    final strings = ref.read(l10nProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.error),
        ),
        title: Text(
          strings.prog.eraseProgram.t,
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.error),
        ),
        content: Text(
          '${strings.prog.confirmErase.t}\n"${program.name.t}"?',
          style: AppTextStyles.instrumentLabel.copyWith(
            color: Colors.white,
            height: 1.5,
          ),
        ),
        actions: [
          _cancelButton(context, strings),
          _confirmButton(strings.core.delete, () {
            ref
                .read(flightProgramsProvider(profileId).notifier)
                .deleteProgram(program.id);
            Navigator.pop(context);
          }, isError: true),
        ],
      ),
    );
  }

  static Widget _cancelButton(BuildContext context, dynamic strings) =>
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(
          strings.core.cancel.t,
          style: AppTextStyles.instrumentLabel,
        ),
      );

  static Widget _confirmButton(
    String label,
    VoidCallback onPressed, {
    bool isError = false,
  }) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: isError ? AppColors.error : AppColors.primary,
      foregroundColor: isError ? Colors.white : Colors.black,
      shape: const BeveledRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4)),
      ),
    ),
    child: Text(label.t, style: AppTextStyles.button),
  );
}
