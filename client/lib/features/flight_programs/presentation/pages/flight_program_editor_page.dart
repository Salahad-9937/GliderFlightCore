import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../../core/presentation/widgets/instrument_value.dart';
import '../../domain/entities/flight_program.dart';
import '../../domain/entities/flight_program_step.dart';
import '../providers/flight_programs_providers.dart';
import '../providers/program_id_provider.dart';
import '../widgets/add_edit_step_dialog.dart';

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
  FlightProgram? _program;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final programIdObj = ProgramId(
      profileId: widget.profileId,
      programId: widget.programId,
    );
    final initialProgram = ref.read(programByIdProvider(programIdObj));
    if (initialProgram != null) {
      _program = FlightProgram(
        id: initialProgram.id,
        name: initialProgram.name,
        steps: List.from(initialProgram.steps),
      );
    }
  }

  double get _totalDurationSec {
    if (_program == null) return 0;
    final totalMs = _program!.steps.fold(
      0,
      (sum, step) => sum + step.totalDelayMs,
    );
    return totalMs / 1000.0;
  }

  void _saveChanges() {
    if (_program != null) {
      ref
          .read(flightProgramsControllerProvider)
          .updateProgram(widget.profileId, _program!);
      setState(() => _hasChanges = false);
      final strings = ref.read(l10nProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(strings.prog.missionDataSaved.toUpperCase()),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(l10nProvider);
    if (_program == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(strings);
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
                _program!.name.toUpperCase(),
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
              onPressed: _saveChanges,
              icon: Icon(
                Icons.save,
                color: _hasChanges ? AppColors.warning : AppColors.primary,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              _buildMissionSummary(strings),
              Expanded(
                child: _program!.steps.isEmpty
                    ? _EmptySteps(strings: strings)
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _program!.steps.length,
                        itemBuilder: (context, index) => _StepCard(
                          step: _program!.steps[index],
                          index: index,
                          strings: strings,
                          onTap: () => _editStep(index),
                          onDelete: () => _deleteStep(index),
                        ),
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addStep,
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

  Widget _buildMissionSummary(dynamic strings) {
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
                value: _totalDurationSec.toStringAsFixed(2),
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
                _hasChanges ? strings.prog.modified : strings.prog.synced,
                style: AppTextStyles.button.copyWith(
                  color: _hasChanges ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addStep() async {
    final newStep = await showAddEditStepDialog(context);
    if (newStep != null) {
      setState(() {
        _program!.steps.add(newStep);
        _hasChanges = true;
      });
    }
  }

  Future<void> _editStep(int index) async {
    final updated = await showAddEditStepDialog(
      context,
      existingStep: _program!.steps[index],
    );
    if (updated != null) {
      setState(() {
        _program!.steps[index] = updated;
        _hasChanges = true;
      });
    }
  }

  void _deleteStep(int index) {
    setState(() {
      _program!.steps.removeAt(index);
      _hasChanges = true;
    });
  }

  Future<bool?> _showExitConfirmation(dynamic strings) {
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

class _StepCard extends StatelessWidget {
  final FlightProgramStep step;
  final int index;
  final dynamic strings;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StepCard({
    required this.step,
    required this.index,
    required this.strings,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InstrumentCard(
        label:
            '${strings.prog.stepNumber.toUpperCase()} ${(index + 1).toString().padLeft(2, '0')}',
        actions: [
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 14, color: AppColors.error),
            visualDensity: VisualDensity.compact,
          ),
        ],
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              _ServoVisualizer(angle: step.angle),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InstrumentValue(
                      value: '${step.angle}',
                      unit: strings.prog.unitDeg,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strings.prog.delayBefore.toUpperCase()}: ${step.delaySec}.${step.delayMs.toString().padLeft(3, '0')}s',
                      style: AppTextStyles.instrumentLabel,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit, size: 16, color: AppColors.borderBright),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServoVisualizer extends StatelessWidget {
  final int angle;
  const _ServoVisualizer({required this.angle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: (angle - 90) * math.pi / 180,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 14),
                Container(
                  width: 14,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
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
