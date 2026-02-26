import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/flight_program_step.dart';

/// Показывает диалог для создания или редактирования шага программы.
///
/// Теперь принимает угол (0-180) и время задержки от предыдущего события.
Future<FlightProgramStep?> showAddEditStepDialog(
  BuildContext context, {
  FlightProgramStep? existingStep,
}) {
  final formKey = GlobalKey<FormState>();

  final angleController = TextEditingController(
    text: existingStep?.angle.toString() ?? '',
  );
  final delaySecController = TextEditingController(
    text: existingStep?.delaySec.toString() ?? '',
  );
  final delayMsController = TextEditingController(
    text: existingStep?.delayMs.toString() ?? '',
  );

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
                  'Положение сервопривода',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: angleController,
                  decoration: const InputDecoration(
                    labelText: 'Угол (градусы)',
                    suffixText: '°',
                    helperText: 'Обычно от 0 до 180',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  autofocus: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Введите угол';
                    final val = int.tryParse(v);
                    if (val == null || val < 0 || val > 180) return '0 - 180';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Задержка перед поворотом',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: delaySecController,
                        decoration: const InputDecoration(labelText: 'Секунды'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: delayMsController,
                        decoration: const InputDecoration(
                          labelText: 'Миллисекунды',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                const SizedBox(height: 8),
                Text(
                  'Время отсчитывается от завершения предыдущего шага.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
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
                final angle = int.tryParse(angleController.text) ?? 0;
                final sec = int.tryParse(delaySecController.text) ?? 0;
                final ms = int.tryParse(delayMsController.text) ?? 0;

                final newStep = FlightProgramStep(
                  angle: angle,
                  delaySec: sec,
                  delayMs: ms,
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
