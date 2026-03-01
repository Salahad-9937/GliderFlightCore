import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
  late TextEditingController _angleController;
  late TextEditingController _secController;
  late TextEditingController _msController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _angleController = TextEditingController(
      text: widget.existingStep?.angle.toString() ?? '90',
    );
    _secController = TextEditingController(
      text: widget.existingStep?.delaySec.toString() ?? '0',
    );
    _msController = TextEditingController(
      text: widget.existingStep?.delayMs.toString() ?? '0',
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.read(l10nProvider);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primary),
      ),
      title: Text(strings.prog.stepConfig, style: AppTextStyles.sectionTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildField(
                controller: _angleController,
                label: strings.prog.servoAngle,
                icon: Icons.rotate_right,
                strings: strings,
                max: 180,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _secController,
                      label: strings.prog.seconds.toUpperCase(),
                      icon: Icons.timer_outlined,
                      strings: strings,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      controller: _msController,
                      label: strings.prog.milliseconds.toUpperCase(),
                      icon: Icons.speed,
                      strings: strings,
                      max: 999,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            strings.core.cancel.toUpperCase(),
            style: AppTextStyles.instrumentLabel,
          ),
        ),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            shape: const BeveledRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
          child: Text(strings.prog.confirm, style: AppTextStyles.button),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppStrings strings,
    int? max,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: AppTextStyles.telemetryValueMedium.copyWith(
        fontSize: 20,
        color: AppColors.primary,
      ),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 16, color: AppColors.borderBright),
        labelText: label,
        labelStyle: AppTextStyles.instrumentLabel,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorStyle: AppTextStyles.instrumentLabel.copyWith(
          color: AppColors.error,
          fontSize: 9,
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return strings.core.error.toUpperCase();
        final val = int.tryParse(v);
        if (val == null) return strings.core.error.toUpperCase();
        if (max != null && val > max) return 'MAX $max';
        return null;
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        FlightProgramStep(
          angle: int.parse(_angleController.text),
          delaySec: int.parse(_secController.text),
          delayMs: int.parse(_msController.text),
        ),
      );
    }
  }
}
