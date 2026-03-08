import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../device_communication/presentation/providers/program_upload_controller.dart';
import '../../domain/entities/flight_program.dart';
import '../pages/flight_program_editor_page.dart';
import 'flight_program_dialogs.dart';

class ProgramCard extends ConsumerWidget {
  final String profileId;
  final FlightProgram program;
  final int index;

  const ProgramCard({
    super.key,
    required this.profileId,
    required this.program,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);

    return InstrumentCard(
      label: 'PROGRAM ${index.toString().padLeft(2, '0')}',
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_horiz,
            size: 16,
            color: AppColors.primary,
          ),
          onSelected: (val) => _onAction(context, ref, val, strings),
          color: AppColors.surfaceLight,
          itemBuilder: (context) => [
            _item('upload', Icons.upload, strings.prog.uploadToDevice),
            _item(
              'delete',
              Icons.delete_outline,
              strings.core.delete,
              isError: true,
            ),
          ],
        ),
      ],
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FlightProgramEditorPage(
              profileId: profileId,
              programId: program.id,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.terminal, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.name.t,
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${strings.prog.stepNumber.t}S: ${program.steps.length.toString().padLeft(2, '0')}',
                    style: AppTextStyles.instrumentLabel.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppColors.borderBright,
            ),
          ],
        ),
      ),
    );
  }

  void _onAction(
    BuildContext context,
    WidgetRef ref,
    String val,
    AppStrings strings,
  ) async {
    switch (val) {
      case 'upload':
        final res = await ref
            .read(programUploadControllerProvider)
            .uploadProgram(program);
        if (!context.mounted) return;
        _showStatus(
          context,
          res == UploadResult.success
              ? strings.prog.uploadSuccess
              : strings.prog.uploadError,
          res == UploadResult.success,
        );
      case 'delete':
        FlightProgramDialogs.showDelete(context, ref, profileId, program);
    }
  }

  void _showStatus(BuildContext context, String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg.t),
        backgroundColor: ok ? AppColors.success : AppColors.error,
      ),
    );
  }

  PopupMenuItem<String> _item(
    String val,
    IconData icon,
    String label, {
    bool isError = false,
  }) => PopupMenuItem(
    value: val,
    child: Row(
      children: [
        Icon(icon, size: 18, color: isError ? AppColors.error : Colors.white),
        const SizedBox(width: 12),
        Text(
          label.t,
          style: AppTextStyles.instrumentLabel.copyWith(
            color: isError ? AppColors.error : Colors.white,
          ),
        ),
      ],
    ),
  );
}
