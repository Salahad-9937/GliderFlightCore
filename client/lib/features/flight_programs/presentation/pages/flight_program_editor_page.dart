import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../providers/program_editor_provider.dart';
import '../widgets/add_edit_step_dialog.dart';
import '../widgets/empty_steps.dart';
import '../widgets/flight_program_editor_app_bar.dart';
import '../widgets/mission_step_card.dart';
import '../widgets/mission_summary.dart';

class FlightProgramEditorPage extends ConsumerStatefulWidget {
  final String profileId;
  final String programId;

  const FlightProgramEditorPage({
    super.key,
    required this.profileId,
    required this.programId,
  });

  @override
  ConsumerState<FlightProgramEditorPage> createState() =>
      _FlightProgramEditorPageState();
}

class _FlightProgramEditorPageState
    extends ConsumerState<FlightProgramEditorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(programEditorProvider.notifier)
          .init(widget.profileId, widget.programId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(programEditorProvider);
    final notifier = ref.read(programEditorProvider.notifier);
    final strings = ref.watch(l10nProvider);
    final program = editorState.program;

    if (program == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return PopScope(
      canPop: !editorState.hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context, strings);
        if (shouldPop == true && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: FlightProgramEditorAppBar(
          program: program,
          hasChanges: editorState.hasChanges,
          onSave: () {
            notifier.saveChanges();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(strings.prog.missionDataSaved.t),
                backgroundColor: AppColors.success,
              ),
            );
          },
        ),
        body: SafeArea(
          child: Column(
            children: [
              MissionSummary(
                program: program,
                hasChanges: editorState.hasChanges,
                strings: strings,
              ),
              Expanded(
                // Изоляция отрисовки списка для производительности (Stage 14.4)
                child: RepaintBoundary(
                  child: program.steps.isEmpty
                      ? EmptySteps(strings: strings)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: program.steps.length,
                          itemBuilder: (context, index) => MissionStepCard(
                            step: program.steps[index],
                            index: index,
                            strings: strings,
                            onTap: () async {
                              final updated = await showAddEditStepDialog(
                                context,
                                existingStep: program.steps[index],
                              );
                              if (updated != null) {
                                notifier.updateStep(index, updated);
                              }
                            },
                            onDelete: () => notifier.deleteStep(index),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newStep = await showAddEditStepDialog(context);
            if (newStep != null) notifier.addStep(newStep);
          },
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape: const BeveledRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          child: const Icon(Icons.add_task),
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation(BuildContext context, dynamic strings) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.warning),
        ),
        title: Text(
          strings.prog.unsavedData.t,
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.warning),
        ),
        content: Text(
          strings.prog.abortEditing.t,
          style: AppTextStyles.instrumentLabel.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              strings.core.cancel.t,
              style: AppTextStyles.instrumentLabel,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              strings.prog.exit.t,
              style: AppTextStyles.instrumentLabel.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
