import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/flight_program_step.dart';

/// Показывает диалог для создания или редактирования шага программы.
Future<FlightProgramStep?> showAddEditStepDialog(
  BuildContext context, {
  FlightProgramStep? existingStep,
}) {
  final formKey = GlobalKey<FormState>();
  
  final durationSecController = TextEditingController(text: existingStep?.durationSec.toString() ?? '');
  final durationMsController = TextEditingController(text: existingStep?.durationMs.toString() ?? '');
  final directionNotifier = ValueNotifier<int>(existingStep?.direction ?? 1);

  return showDialog<FlightProgramStep>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(existingStep == null ? 'Новый шаг' : 'Редактировать шаг'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Длительность вращения',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: durationSecController,
                        decoration: const InputDecoration(labelText: 'Секунды'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        autofocus: true, // Фокус на первом поле ввода
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: durationMsController,
                        decoration: const InputDecoration(labelText: 'Миллисекунды'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          final ms = int.tryParse(v);
                          if (ms != null && ms > 999) return 'Макс. 999';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                ValueListenableBuilder<int>(
                  valueListenable: directionNotifier,
                  builder: (context, direction, child) {
                    return SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 1, label: Text('По часовой'), icon: Icon(Icons.rotate_right)),
                        ButtonSegment(value: -1, label: Text('Против'), icon: Icon(Icons.rotate_left)),
                      ],
                      selected: {direction},
                      onSelectionChanged: (newSelection) {
                        directionNotifier.value = newSelection.first;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final sec = int.tryParse(durationSecController.text) ?? 0;
                final ms = int.tryParse(durationMsController.text) ?? 0;

                if (sec == 0 && ms == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Длительность вращения не может быть нулевой'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }

                final newStep = FlightProgramStep(
                  direction: directionNotifier.value,
                  durationSec: sec,
                  durationMs: ms,
                );
                Navigator.of(context).pop(newStep);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      );
    },
  );
}