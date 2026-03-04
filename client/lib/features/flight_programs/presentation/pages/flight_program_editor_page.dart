import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_value.dart';
import '../providers/program_editor_provider.dart';
import '../widgets/add_edit_step_dialog.dart';
import '../widgets/mission_step_card.dart';

/// Страница редактора полетной программы.
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
        if (shouldPop == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.name.toUpperCase(),
                style: AppTextStyles.sectionTitle,
              ),
              Text(
                strings.prog.missionSequenceEditor,
                style: AppTextStyles.instrumentLabel,
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () {
                notifier.saveChanges();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(strings.prog.missionDataSaved.toUpperCase()),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              icon: Icon(
                Icons.save,
                color: editorState.hasChanges
                    ? AppColors.warning
                    : AppColors.primary,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _MissionSummary(
                totalDurationSec: program.totalDurationSec,
                hasChanges: editorState.hasChanges,
                strings: strings,
              ),
              Expanded(
                child: program.steps.isEmpty
                    ? _EmptySteps(strings: strings)
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
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newStep = await showAddEditStepDialog(context);
            if (newStep != null) {
              notifier.addStep(newStep);
            }
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
          strings.prog.unsavedData,
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.warning),
        ),
        content: Text(
          strings.prog.abortEditing,
          style: AppTextStyles.instrumentLabel.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              strings.core.cancel.toUpperCase(),
              style: AppTextStyles.instrumentLabel,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              strings.prog.exit.toUpperCase(),
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

class _MissionSummary extends StatelessWidget {
  final double totalDurationSec;
  final bool hasChanges;
  final dynamic strings;

  const _MissionSummary({
    required this.totalDurationSec,
    required this.hasChanges,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.prog.totalMissionTime,
                style: AppTextStyles.instrumentLabel,
              ),
              InstrumentValue(
                value: totalDurationSec.toStringAsFixed(2),
                unit: strings.prog.unitSecShort,
                valueStyle: AppTextStyles.telemetryValueMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                strings.prog.sequenceStatus,
                style: AppTextStyles.instrumentLabel,
              ),
              Text(
                hasChanges ? strings.prog.modified : strings.prog.synced,
                style: AppTextStyles.button.copyWith(
                  color: hasChanges ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptySteps extends StatelessWidget {
  final dynamic strings;
  const _EmptySteps({required this.strings});
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      strings.prog.noMissionSteps,
      style: AppTextStyles.instrumentLabel.copyWith(
        color: AppColors.borderBright,
      ),
    ),
  );
}
