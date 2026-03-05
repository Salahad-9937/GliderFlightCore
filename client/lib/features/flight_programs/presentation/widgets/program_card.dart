import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../device_communication/presentation/providers/program_upload_controller.dart';
import '../../domain/entities/flight_program.dart';
import '../pages/flight_program_editor_page.dart';
import 'delete_program_dialog.dart';

/// Виджет карточки программы в списке.
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
          onSelected: (val) => _handleMenuAction(context, ref, val, strings),
          color: AppColors.surfaceLight,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'upload',
              child: _buildPopupItem(Icons.upload, strings.prog.uploadToDevice),
            ),
            PopupMenuItem(
              value: 'delete',
              child: _buildPopupItem(
                Icons.delete_outline,
                strings.core.delete,
                isError: true,
              ),
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

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String val,
    dynamic strings,
  ) async {
    if (val == 'upload') {
      final res = await ref
          .read(programUploadControllerProvider)
          .uploadProgram(program);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (res == UploadResult.success
                    ? strings.prog.uploadSuccess
                    : strings.prog.uploadError)
                .t,
          ),
          backgroundColor: res == UploadResult.success
              ? AppColors.success
              : AppColors.error,
        ),
      );
    } else if (val == 'delete') {
      showDeleteProgramDialog(context, ref, profileId, program);
    }
  }

  Widget _buildPopupItem(IconData icon, String label, {bool isError = false}) {
    return Row(
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
    );
  }
}
