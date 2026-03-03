import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_encoder.dart';
import '../../domain/entities/flight_program_step.dart';
import '../../domain/value_objects/servo_angle.dart';
import '../../domain/value_objects/step_duration.dart';

part 'add_edit_step_dialog.g.dart';

/// ViewModel для управления состоянием формы.
/// Параметр [initial] в build() автоматически делает провайдер «семьей» (.family).
@riverpod
final class StepEditor extends _$StepEditor {
  @override
  FlightProgramStep build(FlightProgramStep? initial) {
    // Весь мертвый код с init() удален. Начальное состояние берется из параметров.
    return initial ??
        const FlightProgramStep(
          angle: ServoAngle(90),
          duration: StepDuration(0),
        );
  }

  void updateAngle(int val) {
    state = state.copyWith(angle: ServoAngle(val));
  }

  void updateFromKnob(String type, double knobValue) {
    int newTotalMs = state.duration.totalMs;
    if (type == 'min') {
      newTotalMs += (knobValue - state.duration.minutes).toInt() * 60000;
    } else if (type == 'sec') {
      newTotalMs += (knobValue - state.duration.secondsOnly).toInt() * 1000;
    } else if (type == 'ms') {
      newTotalMs += (knobValue - state.duration.millisOnly).toInt();
    }
    state = state.copyWith(duration: StepDuration(newTotalMs));
  }

  void updateFromText(String type, int val) {
    if (type == 'angle') {
      updateAngle(val);
    } else {
      int m = state.duration.minutes;
      int s = state.duration.secondsOnly;
      int ms = state.duration.millisOnly;
      if (type == 'min') m = val;
      if (type == 'sec') s = val;
      if (type == 'ms') ms = val;
      state = state.copyWith(
        duration: StepDuration.fromComponents(min: m, sec: s, ms: ms),
      );
    }
  }
}

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

  @override
  void initState() {
    super.initState();
    // Используем данные напрямую, мертвый код инициализации провайдера удален.
    final initial =
        widget.existingStep ??
        const FlightProgramStep(
          angle: ServoAngle(90),
          duration: StepDuration(0),
        );

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
    _angleController.dispose();
    _minController.dispose();
    _secController.dispose();
    _msController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Теперь обращаемся к провайдеру как к функции, передавая initial данные.
    final stepProvider = stepEditorProvider(widget.existingStep);
    final step = ref.watch(stepProvider);
    final notifier = ref.read(stepProvider.notifier);
    final strings = ref.read(l10nProvider);

    ref.listen<FlightProgramStep>(stepProvider, (prev, next) {
      if (_angleController.text != next.angle.value.toString()) {
        _angleController.text = next.angle.value.toString();
      }
      if (_minController.text != next.duration.minutes.toString()) {
        _minController.text = next.duration.minutes.toString();
      }
      if (_secController.text != next.duration.secondsOnly.toString()) {
        _secController.text = next.duration.secondsOnly.toString();
      }
      if (_msController.text != next.duration.millisOnly.toString()) {
        _msController.text = next.duration.millisOnly.toString();
      }
    });

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
                children: [
                  _buildEncoderColumn(
                    value: step.angle.value.toDouble(),
                    max: ServoAngle.max.toDouble(),
                    label: strings.prog.servoAngle,
                    unit: strings.prog.unitDeg,
                    controller: _angleController,
                    onKnob: (v) => notifier.updateAngle(v.toInt()),
                    onText: (v) =>
                        notifier.updateFromText('angle', int.tryParse(v) ?? 0),
                  ),
                  const SizedBox(width: 16),
                  _buildEncoderColumn(
                    value: step.duration.minutes.toDouble(),
                    max: 60,
                    label: strings.panel.unitMin.toUpperCase(),
                    unit: 'МИН',
                    controller: _minController,
                    onKnob: (v) => notifier.updateFromKnob('min', v),
                    onText: (v) =>
                        notifier.updateFromText('min', int.tryParse(v) ?? 0),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: AppColors.border),
              ),
              Row(
                children: [
                  _buildEncoderColumn(
                    value: step.duration.secondsOnly.toDouble(),
                    max: 60,
                    isInfinite: true,
                    label: strings.prog.seconds,
                    unit: strings.prog.unitSecShort,
                    controller: _secController,
                    onKnob: (v) => notifier.updateFromKnob('sec', v),
                    onText: (v) =>
                        notifier.updateFromText('sec', int.tryParse(v) ?? 0),
                  ),
                  const SizedBox(width: 16),
                  _buildEncoderColumn(
                    value: step.duration.millisOnly.toDouble(),
                    max: 1000,
                    isInfinite: true,
                    label: strings.prog.milliseconds,
                    unit: 'MS',
                    controller: _msController,
                    onKnob: (v) => notifier.updateFromKnob('ms', v),
                    onText: (v) =>
                        notifier.updateFromText('ms', int.tryParse(v) ?? 0),
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
          onPressed: () => Navigator.pop(context, step),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          child: Text(strings.prog.confirm, style: AppTextStyles.button),
        ),
      ],
    );
  }

  Widget _buildEncoderColumn({
    required double value,
    required double max,
    required String label,
    required String unit,
    required TextEditingController controller,
    required ValueChanged<double> onKnob,
    required ValueChanged<String> onText,
    bool isInfinite = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          InstrumentEncoder(
            value: value,
            min: 0,
            max: max,
            fullTurnValue: max,
            isInfinite: isInfinite,
            label: label,
            unit: unit,
            onChanged: onKnob,
          ),
          const SizedBox(height: 8),
          _buildManualInput(controller, onText),
        ],
      ),
    );
  }

  Widget _buildManualInput(
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) {
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
        onChanged: onChanged,
      ),
    );
  }
}
