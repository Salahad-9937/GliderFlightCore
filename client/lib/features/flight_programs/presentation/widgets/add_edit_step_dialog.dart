import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/presentation/widgets/tactical_encoder_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/flight_program_step.dart';
import '../../domain/value_objects/servo_angle.dart';
import '../providers/step_editor_provider.dart';

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

  @override
  void initState() {
    super.initState();
    final initial = ref.read(stepEditorProvider(widget.existingStep));
    _angleController = TextEditingController(
      text: initial.angle.value.toString(),
    );
    _minController = TextEditingController(
      text: initial.duration.minutes.toString(),
    );
    _secController = TextEditingController(
      text: initial.duration.secondsOnly.toString(),
    );
    _msController = TextEditingController(
      text: initial.duration.millisOnly.toString(),
    );
  }

  @override
  void dispose() {
    for (var c in [
      _angleController,
      _minController,
      _secController,
      _msController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepProvider = stepEditorProvider(widget.existingStep);
    final step = ref.watch(stepProvider);
    final notifier = ref.read(stepProvider.notifier);
    final strings = ref.read(l10nProvider);

    ref.listen<FlightProgramStep>(stepProvider, (prev, next) {
      _updateIfChanged(_angleController, next.angle.value.toString());
      _updateIfChanged(_minController, next.duration.minutes.toString());
      _updateIfChanged(_secController, next.duration.secondsOnly.toString());
      _updateIfChanged(_msController, next.duration.millisOnly.toString());
    });

    return AlertDialog(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primary),
      ),
      title: Text(strings.prog.stepConfig.t, style: AppTextStyles.sectionTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                TacticalEncoderField(
                  value: step.angle.value.toDouble(),
                  max: ServoAngle.max.toDouble(),
                  label: strings.prog.servoAngle,
                  unit: strings.prog.unitDeg.t,
                  controller: _angleController,
                  onKnobChanged: (v) => notifier.updateAngle(v.toInt()),
                  onTextChanged: (v) => notifier.updateFromText(
                    DurationComponent.angle,
                    int.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 16),
                TacticalEncoderField(
                  value: step.duration.minutes.toDouble(),
                  max: 60,
                  label: strings.panel.unitMin,
                  unit: 'МИН',
                  controller: _minController,
                  onKnobChanged: (v) =>
                      notifier.updateFromKnob(DurationComponent.min, v),
                  onTextChanged: (v) => notifier.updateFromText(
                    DurationComponent.min,
                    int.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: AppColors.border),
            ),
            Row(
              children: [
                TacticalEncoderField(
                  value: step.duration.secondsOnly.toDouble(),
                  max: 60,
                  isInfinite: true,
                  label: strings.prog.seconds,
                  unit: strings.prog.unitSecShort.t,
                  controller: _secController,
                  onKnobChanged: (v) =>
                      notifier.updateFromKnob(DurationComponent.sec, v),
                  onTextChanged: (v) => notifier.updateFromText(
                    DurationComponent.sec,
                    int.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 16),
                TacticalEncoderField(
                  value: step.duration.millisOnly.toDouble(),
                  max: 1000,
                  isInfinite: true,
                  label: strings.prog.milliseconds,
                  unit: 'MS',
                  controller: _msController,
                  onKnobChanged: (v) =>
                      notifier.updateFromKnob(DurationComponent.ms, v),
                  onTextChanged: (v) => notifier.updateFromText(
                    DurationComponent.ms,
                    int.tryParse(v) ?? 0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            strings.core.cancel.t,
            style: AppTextStyles.instrumentLabel,
          ),
        ),
        FilledButton(
          onPressed: () {
            if (notifier.isDurationValid) {
              Navigator.pop(context, step);
            } else {
              _showZeroDurationWarning(context, strings);
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          child: Text(strings.prog.confirm.t, style: AppTextStyles.button),
        ),
      ],
    );
  }

  void _showZeroDurationWarning(BuildContext context, AppStrings strings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: AppColors.warning),
        ),
        title: Text(
          strings.prog.invalidDurationTitle.t,
          style: AppTextStyles.sectionTitle.copyWith(color: AppColors.warning),
        ),
        content: Text(
          strings.prog.zeroDurationError.t,
          style: AppTextStyles.instrumentLabel.copyWith(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.core.ok.t, style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  void _updateIfChanged(TextEditingController c, String v) {
    if (c.text != v) c.text = v;
  }
}
