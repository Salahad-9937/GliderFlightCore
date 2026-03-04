import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_encoder.dart';
import '../../domain/entities/flight_program_step.dart';
import '../../domain/value_objects/servo_angle.dart';
import '../providers/step_editor_provider.dart';

/// Вызов диалога добавления или редактирования шага.
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

    // Читаем начальное состояние из провайдера для инициализации контроллеров
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
    _angleController.dispose();
    _minController.dispose();
    _secController.dispose();
    _msController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stepProvider = stepEditorProvider(widget.existingStep);
    final step = ref.watch(stepProvider);
    final notifier = ref.read(stepProvider.notifier);
    final strings = ref.read(l10nProvider);

    // Синхронизация текстовых полей при изменении состояния (например, через энкодер)
    ref.listen<FlightProgramStep>(stepProvider, (prev, next) {
      _updateController(_angleController, next.angle.value.toString());
      _updateController(_minController, next.duration.minutes.toString());
      _updateController(_secController, next.duration.secondsOnly.toString());
      _updateController(_msController, next.duration.millisOnly.toString());
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
                    onText: (v) => notifier.updateFromText(
                      DurationComponent.angle,
                      int.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildEncoderColumn(
                    value: step.duration.minutes.toDouble(),
                    max: 60,
                    label: strings.panel.unitMin.toUpperCase(),
                    unit: 'МИН',
                    controller: _minController,
                    onKnob: (v) =>
                        notifier.updateFromKnob(DurationComponent.min, v),
                    onText: (v) => notifier.updateFromText(
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
                  _buildEncoderColumn(
                    value: step.duration.secondsOnly.toDouble(),
                    max: 60,
                    isInfinite: true,
                    label: strings.prog.seconds,
                    unit: strings.prog.unitSecShort,
                    controller: _secController,
                    onKnob: (v) =>
                        notifier.updateFromKnob(DurationComponent.sec, v),
                    onText: (v) => notifier.updateFromText(
                      DurationComponent.sec,
                      int.tryParse(v) ?? 0,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildEncoderColumn(
                    value: step.duration.millisOnly.toDouble(),
                    max: 1000,
                    isInfinite: true,
                    label: strings.prog.milliseconds,
                    unit: 'MS',
                    controller: _msController,
                    onKnob: (v) =>
                        notifier.updateFromKnob(DurationComponent.ms, v),
                    onText: (v) => notifier.updateFromText(
                      DurationComponent.ms,
                      int.tryParse(v) ?? 0,
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

  /// Обновляет текст в контроллере только если он отличается, чтобы не сбивать курсор
  void _updateController(TextEditingController controller, String value) {
    if (controller.text != value) {
      controller.text = value;
    }
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
