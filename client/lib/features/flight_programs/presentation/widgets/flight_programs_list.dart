import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../device_communication/presentation/providers/program_upload_controller.dart';
import '../../domain/entities/flight_program.dart';
import '../pages/flight_program_editor_page.dart';
import '../providers/flight_programs_providers.dart';
import 'add_program_dialog.dart';
import 'delete_program_dialog.dart';

/// Список программ в стиле банка данных.
class FlightProgramsList extends ConsumerWidget {
  final String profileId;
  const FlightProgramsList({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(flightProgramsProvider(profileId));
    final strings = ref.watch(l10nProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.prog.programsTitle.toUpperCase(),
              style: AppTextStyles.sectionTitle,
            ),
            IconButton(
              onPressed: () => showAddProgramDialog(context, ref, profileId),
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 12),
        programsAsync.when(
          data: (programs) => programs.isEmpty
              ? _EmptyCard(strings: strings)
              : Column(
                  children: [
                    for (int i = 0; i < programs.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _ProgramCard(
                          profileId: profileId,
                          program: programs[i],
                          index: i + 1,
                        ),
                      ),
                  ],
                ),
          loading: () => const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
          ),
          error: (e, _) => Text(
            '${strings.core.systemErrorPrefix}: $e'.toUpperCase(),
            style: AppTextStyles.instrumentLabel.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends ConsumerWidget {
  final String profileId;
  final FlightProgram program;
  final int index;

  const _ProgramCard({
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
          onSelected: (val) async {
            if (val == 'upload') {
              final res = await ref
                  .read(programUploadControllerProvider)
                  .uploadProgram(program);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    res == UploadResult.success
                        ? strings.prog.uploadSuccess
                        : strings.prog.uploadError,
                  ),
                  backgroundColor: res == UploadResult.success
                      ? AppColors.success
                      : AppColors.error,
                ),
              );
            } else if (val == 'delete') {
              showDeleteProgramDialog(context, ref, profileId, program);
            }
          },
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
                    program.name.toUpperCase(),
                    style: AppTextStyles.button.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${strings.prog.stepNumber.toUpperCase()}S: ${program.steps.length.toString().padLeft(2, '0')}',
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

  Widget _buildPopupItem(IconData icon, String label, {bool isError = false}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: isError ? AppColors.error : Colors.white),
        const SizedBox(width: 12),
        Text(
          label.toUpperCase(),
          style: AppTextStyles.instrumentLabel.copyWith(
            color: isError ? AppColors.error : Colors.white,
          ),
        ),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final dynamic strings;
  const _EmptyCard({required this.strings});
  @override
  Widget build(BuildContext context) => InstrumentCard(
    child: Row(
      children: [
        const Icon(Icons.layers_clear, color: AppColors.border, size: 20),
        const SizedBox(width: 12),
        Text(
          strings.prog.noPrograms.toUpperCase(),
          style: AppTextStyles.instrumentLabel,
        ),
      ],
    ),
  );
}
