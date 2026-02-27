import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../domain/entities/flight_program_step.dart';

Future<FlightProgramStep?> showAddEditStepDialog(
  BuildContext context, {
  FlightProgramStep? existingStep,
}) {
  return showDialog<FlightProgramStep>(
    context: context,
    builder: (context) => _StepDialog(existingStep: existingStep),
  );
}

class _StepDialog extends ConsumerStatefulWidget {
  final FlightProgramStep? existingStep;
  const _StepDialog({this.existingStep});

  @override
  ConsumerState<_StepDialog> createState() => _StepDialogState();
}

class _StepDialogState extends ConsumerState<_StepDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _angleController;
  late final TextEditingController _secController;
  late final TextEditingController _msController;

  @override
  void initState() {
    super.initState();
    _angleController = TextEditingController(
      text: widget.existingStep?.angle.toString() ?? '',
    );
    _secController = TextEditingController(
      text: widget.existingStep?.delaySec.toString() ?? '',
    );
    _msController = TextEditingController(
      text: widget.existingStep?.delayMs.toString() ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(l10nProvider);

    return AlertDialog(
      title: Text(
        widget.existingStep == null ? strings.stepNumber : strings.edit,
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.angleLabel,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _angleController,
                decoration: InputDecoration(
                  suffixText: '°',
                  helperText: strings.angleHelper,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                autofocus: true,
                validator: (v) {
                  final val = int.tryParse(v ?? '');
                  if (val == null || val < 0 || val > 180) {
                    return strings.angleError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                strings.delayBefore,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _secController,
                      decoration: InputDecoration(labelText: strings.seconds),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _msController,
                      decoration: InputDecoration(
                        labelText: strings.milliseconds,
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        final ms = int.tryParse(v ?? '');
                        if (ms != null && ms > 999) return strings.msMaxError;
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                strings.delayDesc,
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
          onPressed: () => Navigator.pop(context),
          child: Text(strings.cancel),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                context,
                FlightProgramStep(
                  angle: int.parse(_angleController.text),
                  delaySec: int.tryParse(_secController.text) ?? 0,
                  delayMs: int.tryParse(_msController.text) ?? 0,
                ),
              );
            }
          },
          child: Text(strings.save),
        ),
      ],
    );
  }
}
