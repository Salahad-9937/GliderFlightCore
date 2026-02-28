import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../device_communication/presentation/providers/program_upload_controller.dart';
import '../../domain/entities/flight_program.dart';
import '../pages/flight_program_editor_page.dart';
import '../providers/flight_programs_providers.dart';
import 'add_program_dialog.dart';
import 'delete_program_dialog.dart';

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
            Text(strings.prog.programsTitle, style: AppTextStyles.title),
            IconButton(
              onPressed: () => showAddProgramDialog(context, ref, profileId),
              icon: const Icon(Icons.add_circle_outline),
              tooltip: strings.prog.createProgram,
            ),
          ],
        ),
        const SizedBox(height: 8),
        programsAsync.when(
          data: (programs) => programs.isEmpty
              ? _EmptyCard(strings: strings)
              : Column(
                  children: [
                    for (final p in programs)
                      _ProgramCard(profileId: profileId, program: p),
                  ],
                ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: ListTile(
              title: Text(
                '${strings.core.error}: $e',
                style: AppTextStyles.body,
              ),
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
  const _ProgramCard({required this.profileId, required this.program});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(
          program.name,
          style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${strings.prog.stepNumber}ов: ${program.steps.length}',
          style: AppTextStyles.telemetryLabel,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FlightProgramEditorPage(
              profileId: profileId,
              programId: program.id,
            ),
          ),
        ),
        trailing: PopupMenuButton<String>(
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
                    style: AppTextStyles.body,
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
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'upload',
              child: ListTile(
                leading: const Icon(Icons.upload),
                title: Text(
                  strings.prog.uploadToDevice,
                  style: AppTextStyles.body,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: Text(
                  strings.core.delete,
                  style: AppTextStyles.body.copyWith(color: AppColors.error),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final AppStrings strings;
  const _EmptyCard({required this.strings});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.playlist_add_check_circle_outlined),
      title: Text(
        strings.prog.noPrograms,
        style: AppTextStyles.body.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        strings.prog.addFirstProgram,
        style: AppTextStyles.telemetryLabel,
      ),
    ),
  );
}
