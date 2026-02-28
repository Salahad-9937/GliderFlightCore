import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/flight_program.dart';
import '../providers/flight_programs_providers.dart';

void showDeleteProgramDialog(
  BuildContext context,
  WidgetRef ref,
  String profileId,
  FlightProgram program,
) {
  final strings = ref.read(l10nProvider);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.core.confirmation, style: AppTextStyles.title),
      content: Text(
        '${strings.prog.deleteProgramConfirm} "${program.name}"?',
        style: AppTextStyles.body,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.core.cancel, style: AppTextStyles.body),
        ),
        FilledButton.tonal(
          onPressed: () {
            ref
                .read(flightProgramsControllerProvider)
                .deleteProgram(profileId, program.id);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  strings.prog.programDeleted,
                  style: AppTextStyles.body,
                ),
              ),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
          ),
          child: Text(
            strings.core.delete,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
