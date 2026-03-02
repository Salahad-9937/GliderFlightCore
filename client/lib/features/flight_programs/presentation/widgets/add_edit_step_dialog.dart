import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_encoder.dart';
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
  late TextEditingController _minController;
  late TextEditingController _secController;
  late TextEditingController _msController;
  final _formKey = GlobalKey<FormState>();

  /// Текущий редактируемый шаг (State-контейнер)
  late FlightProgramStep _currentStep;

  @override
  void initState() {
    super.initState();
    _currentStep = widget.existingStep ?? const FlightProgramStep(angle: 90);

    _angleController = TextEditingController(
      text: _currentStep.angle.toString(),
    );
    _minController = TextEditingController(
      text: _currentStep.minutes.toString(),
    );
    _secController = TextEditingController(
      text: _currentStep.secondsOnly.toString(),
    );
    _msController = TextEditingController(
      text: _currentStep.millisOnly.toString(),
    );
  }

  void _syncTextControllers() {
    _angleController.text = _currentStep.angle.toString();
    _minController.text = _currentStep.minutes.toString();
    _secController.text = _currentStep.secondsOnly.toString();
    _msController.text = _currentStep.millisOnly.toString();
  }

  void _handleKnobChange(String type, double knobValue) {
    setState(() {
      if (type == 'angle') {
        _currentStep = _currentStep.copyWith(angle: knobValue.toInt());
      } else {
        int newTotalMs = _currentStep.totalDelayMs;
        if (type == 'min') {
          newTotalMs += (knobValue - _currentStep.minutes).toInt() * 60000;
        } else if (type == 'sec') {
          newTotalMs += (knobValue - _currentStep.secondsOnly).toInt() * 1000;
        } else if (type == 'ms') {
          newTotalMs += (knobValue - _currentStep.millisOnly).toInt();
        }
        _currentStep = FlightProgramStep.fromTotalMs(
          newTotalMs,
          _currentStep.angle,
        );
      }
      _syncTextControllers();
    });
  }

  void _handleTextChange(String type, String value) {
    final val = int.tryParse(value) ?? 0;
    setState(() {
      if (type == 'angle') {
        _currentStep = _currentStep.copyWith(angle: val);
      } else {
        int m = _currentStep.minutes;
        int s = _currentStep.secondsOnly;
        int ms = _currentStep.millisOnly;

        if (type == 'min') m = val;
        if (type == 'sec') s = val;
        if (type == 'ms') ms = val;

        final total = (m * 60000) + (s * 1000) + ms;
        _currentStep = FlightProgramStep.fromTotalMs(total, _currentStep.angle);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.read(l10nProvider);

    return AlertDialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InstrumentEncoder(
                          value: _currentStep.angle.toDouble(),
                          min: 0,
                          max: 180,
                          fullTurnValue: 180,
                          label: strings.prog.servoAngle,
                          unit: strings.prog.unitDeg,
                          onChanged: (v) => _handleKnobChange('angle', v),
                        ),
                        const SizedBox(height: 8),
                        _buildManualInput(_angleController, 'angle'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        InstrumentEncoder(
                          value: _currentStep.minutes.toDouble(),
                          min: 0,
                          max: 60,
                          fullTurnValue: 60,
                          label: strings.panel.unitMin.toUpperCase(),
                          unit: 'МИН',
                          onChanged: (v) => _handleKnobChange('min', v),
                        ),
                        const SizedBox(height: 8),
                        _buildManualInput(_minController, 'min'),
                      ],
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: AppColors.border),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InstrumentEncoder(
                          value: _currentStep.secondsOnly.toDouble(),
                          isInfinite: true,
                          fullTurnValue: 60,
                          label: strings.prog.seconds,
                          unit: strings.prog.unitSecShort,
                          onChanged: (v) => _handleKnobChange('sec', v),
                        ),
                        const SizedBox(height: 8),
                        _buildManualInput(_secController, 'sec'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        InstrumentEncoder(
                          value: _currentStep.millisOnly.toDouble(),
                          isInfinite: true,
                          fullTurnValue: 1000,
                          step: 10,
                          label: strings.prog.milliseconds,
                          unit: 'MS',
                          onChanged: (v) => _handleKnobChange('ms', v),
                        ),
                        const SizedBox(height: 8),
                        _buildManualInput(_msController, 'ms'),
                      ],
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
          onPressed: () => Navigator.pop(context, _currentStep),
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

  Widget _buildManualInput(TextEditingController controller, String type) {
    return SizedBox(
      width: 70,
      child: TextFormField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: AppTextStyles.telemetryValueMedium.copyWith(fontSize: 16),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        onChanged: (v) => _handleTextChange(type, v),
      ),
    );
  }
}
