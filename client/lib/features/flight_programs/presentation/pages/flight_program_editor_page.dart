import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/flight_program.dart';
import '../../domain/entities/flight_program_step.dart';
import '../providers/flight_programs_providers.dart';
import '../providers/program_id_provider.dart';
import '../widgets/add_edit_step_dialog.dart';

/// Страница редактирования шагов полетной программы.
class FlightProgramEditorPage extends ConsumerStatefulWidget {
  final String profileId;
  final String programId;

  const FlightProgramEditorPage({
    super.key,
    required this.profileId,
    required this.programId,
  });

  @override
  ConsumerState<FlightProgramEditorPage> createState() => _FlightProgramEditorPageState();
}

class _FlightProgramEditorPageState extends ConsumerState<FlightProgramEditorPage> {
  FlightProgram? _program;
  bool _hasChanges = false; // Отслеживание изменений для предупреждения при выходе

  @override
  void initState() {
    super.initState();
    final programIdObj = ProgramId(profileId: widget.profileId, programId: widget.programId);
    final initialProgram = ref.read(programByIdProvider(programIdObj));
    if (initialProgram != null) {
      // Создаем копию программы для редактирования
      _program = FlightProgram.fromMap(initialProgram.toMap());
    }
  }

  Future<void> _addStep() async {
    final newStep = await showAddEditStepDialog(context);
    if (newStep != null && _program != null) {
      setState(() {
        _program!.steps.add(newStep);
        _hasChanges = true;
      });
    }
  }

  Future<void> _editStep(FlightProgramStep stepToEdit, int index) async {
    final updatedStep = await showAddEditStepDialog(context, existingStep: stepToEdit);
    if (updatedStep != null && _program != null) {
      setState(() {
        _program!.steps[index] = updatedStep;
        _hasChanges = true;
      });
    }
  }

  void _deleteStep(int index) {
    if (_program == null) return;
    setState(() {
      _program!.steps.removeAt(index);
      _hasChanges = true;
    });
  }

  void _saveChanges() {
    if (_program != null) {
      ref
          .read(flightProgramsControllerProvider)
          .updateProgram(widget.profileId, _program!);
      setState(() => _hasChanges = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Программа сохранена')),
      );
    }
  }

  /// Показывает диалог подтверждения выхода при наличии изменений.
  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Несохраненные изменения'),
        content: const Text('Вы уверены, что хотите выйти? Изменения будут потеряны.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_program == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Программа не найдена')),
      );
    }

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_program!.name),
          actions: [
            IconButton(onPressed: _saveChanges, icon: const Icon(Icons.save_outlined)),
          ],
        ),
        body: _program!.steps.isEmpty
            ? const _EmptySteps()
            : ListView.builder(
                itemCount: _program!.steps.length,
                itemBuilder: (context, index) {
                  final step = _program!.steps[index];
                  return _StepCard(
                    step: step,
                    stepNumber: index + 1,
                    onTap: () => _editStep(step, index),
                    onDelete: () => _deleteStep(index),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addStep,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.stepNumber,
    required this.onTap,
    required this.onDelete,
  });
  final FlightProgramStep step;
  final int stepNumber;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final durationString = '${step.durationSec} с  ${step.durationMs} мс';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Text('$stepNumber'),
        ),
        title: Text(durationString, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(step.direction == 1 ? 'Направление: По часовой' : 'Направление: Против часовой'),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _EmptySteps extends StatelessWidget {
  const _EmptySteps();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.playlist_add_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text('Нет добавленных шагов', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Нажмите "+", чтобы добавить первый шаг',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}