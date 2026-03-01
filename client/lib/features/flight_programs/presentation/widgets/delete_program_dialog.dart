import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/flight_program.dart';
import '../providers/flight_programs_providers.dart';

void showDeleteProgramDialog(
  BuildContext context,
  WidgetRef ref,
  String profileId,
  FlightProgram program,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.error),
      ),
      title: Text(
        'ERASE PROGRAM',
        style: AppTextStyles.sectionTitle.copyWith(color: AppColors.error),
      ),
      content: Text(
        'CONFIRM DELETION OF MISSION:\n"${program.name.toUpperCase()}"?',
        style: AppTextStyles.instrumentLabel.copyWith(
          color: Colors.white,
          height: 1.5,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('CANCEL', style: AppTextStyles.instrumentLabel),
        ),
        FilledButton(
          onPressed: () {
            ref
                .read(flightProgramsControllerProvider)
                .deleteProgram(profileId, program.id);
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          child: Text('ERASE', style: AppTextStyles.button),
        ),
      ],
    ),
  );
}
