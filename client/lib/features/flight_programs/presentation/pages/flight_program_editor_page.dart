import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../device_communication/presentation/providers/program_upload_controller.dart';
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

  void _saveChanges() {
    if (_program != null) {
      ref
          .read(flightProgramsControllerProvider)
          .updateProgram(widget.profileId, _program!);
      setState(() => _hasChanges = false);
      final strings = ref.read(l10nProvider);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.prog.saveLocalSuccess)));
    }
  }

  Future<void> _uploadToDevice() async {
    if (_program == null) return;
    _saveChanges();

    final result = await ref
        .read(programUploadControllerProvider)
        .uploadProgram(_program!);
    if (!mounted) return;

    final strings = ref.read(l10nProvider);
    switch (result) {
      case UploadResult.success:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.prog.uploadSuccess),
            backgroundColor: AppColors.success,
          ),
        );
        break;
      case UploadResult.failure:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.prog.uploadError),
            backgroundColor: AppColors.error,
          ),
        );
        break;
      case UploadResult.notConnected:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(strings.prog.connectFirst),
            backgroundColor: AppColors.warning,
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(l10nProvider);
    if (_program == null) {
      return Scaffold(body: Center(child: Text(strings.core.error)));
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(strings.prog.unsavedChangesTitle),
            content: Text(strings.prog.unsavedChangesDesc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(strings.core.cancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(strings.prog.exit),
              ),
            ],
          ),
        );
        if (shouldPop == true && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_program!.name),
          actions: [
            IconButton(
              onPressed: _uploadToDevice,
              icon: const Icon(Icons.upload_file_rounded),
              tooltip: strings.prog.uploadToDevice,
            ),
            IconButton(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save_outlined),
              tooltip: strings.core.save,
            ),
          ],
        ),
        body: _program!.steps.isEmpty
            ? _EmptySteps(strings: strings)
            : ListView.builder(
                itemCount: _program!.steps.length,
                itemBuilder: (context, index) {
                  final step = _program!.steps[index];
                  return _StepCard(
                    step: step,
                    stepNumber: index + 1,
                    strings: strings,
                    onTap: () async {
                      final updated = await showAddEditStepDialog(
                        context,
                        existingStep: step,
                      );
                      if (updated != null) {
                        setState(() {
                          _program!.steps[index] = updated;
                          _hasChanges = true;
                        });
                      }
                    },
                    onDelete: () {
                      setState(() {
                        _program!.steps.removeAt(index);
                        _hasChanges = true;
                      });
                    },
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final newStep = await showAddEditStepDialog(context);
            if (newStep != null) {
              setState(() {
                _program!.steps.add(newStep);
                _hasChanges = true;
              });
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final FlightProgramStep step;
  final int stepNumber;
  final AppStrings strings;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StepCard({
    required this.step,
    required this.stepNumber,
    required this.strings,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text('$stepNumber'),
        ),
        title: Text(
          '${strings.prog.angle}: ${step.angle}°',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${step.delaySec} ${strings.panel.unitSec} ${step.delayMs} мс',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EmptySteps extends StatelessWidget {
  final AppStrings strings;
  const _EmptySteps({required this.strings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_add_outlined,
            size: 80,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            strings.prog.noSteps,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            strings.prog.addFirstStep,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
