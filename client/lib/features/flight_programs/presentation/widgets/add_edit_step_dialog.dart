import 'dart:math' as math;
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

  // Главное хранилище времени шага
  int _totalTimeMs = 0;

  double _angle = 90;
  double _minutes = 0;
  double _seconds = 0;
  double _millis = 0;

  @override
  void initState() {
    super.initState();
    _angle = widget.existingStep?.angle.toDouble() ?? 90.0;

    int existingSec = widget.existingStep?.delaySec ?? 0;
    int existingMs = widget.existingStep?.delayMs ?? 0;
    _totalTimeMs = (existingSec * 1000) + existingMs;

    _updateComponentsFromTotal();

    _angleController = TextEditingController(text: _angle.toInt().toString());
    _minController = TextEditingController(text: _minutes.toInt().toString());
    _secController = TextEditingController(text: _seconds.toInt().toString());
    _msController = TextEditingController(text: _millis.toInt().toString());
  }

  void _updateComponentsFromTotal() {
    _minutes = (_totalTimeMs ~/ 60000).toDouble();
    _seconds = ((_totalTimeMs ~/ 1000) % 60).toDouble();
    _millis = (_totalTimeMs % 1000).toDouble();
  }

  void _syncTextControllers() {
    if (_angleController.text != _angle.toInt().toString()) {
      _angleController.text = _angle.toInt().toString();
    }
    if (_minController.text != _minutes.toInt().toString()) {
      _minController.text = _minutes.toInt().toString();
    }
    if (_secController.text != _seconds.toInt().toString()) {
      _secController.text = _seconds.toInt().toString();
    }
    if (_msController.text != _millis.toInt().toString()) {
      _msController.text = _millis.toInt().toString();
    }
  }

  void _handleKnobChange(String type, double knobValue) {
    setState(() {
      if (type == 'angle') {
        _angle = knobValue.clamp(0, 180);
      } else {
        int delta = 0;
        if (type == 'min') {
          delta = (knobValue - _minutes).toInt() * 60000;
        } else if (type == 'sec') {
          delta = (knobValue - _seconds).toInt() * 1000;
        } else if (type == 'ms') {
          delta = (knobValue - _millis).toInt();
        }

        _totalTimeMs += delta;
        // Предотвращаем уход в минус и ограничиваем 60 минутами (3600000 мс)
        _totalTimeMs = math.max(0, math.min(60 * 60000, _totalTimeMs));

        _updateComponentsFromTotal();
      }
      _syncTextControllers();
    });
  }

  void _handleTextChange(String type, String value) {
    final val = int.tryParse(value) ?? 0;
    setState(() {
      if (type == 'angle') {
        _angle = val.clamp(0, 180).toDouble();
      } else {
        if (type == 'min') _minutes = val.toDouble();
        if (type == 'sec') _seconds = val.toDouble();
        if (type == 'ms') _millis = val.toDouble();

        // Пересчет тотала по введенным данным
        _totalTimeMs =
            (_minutes.toInt() * 60000) +
            (_seconds.toInt() * 1000) +
            _millis.toInt();
        _totalTimeMs = math.max(0, math.min(60 * 60000, _totalTimeMs));
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
              // Верхний ряд: Угол и Минуты
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InstrumentEncoder(
                          value: _angle,
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
                          value: _minutes,
                          min: 0,
                          max: 60, // Ограничитель минут
                          fullTurnValue: 60,
                          label: strings.panel.unitMin
                              .toUpperCase(), // Используем из локали
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

              // Нижний ряд: Секунды и Миллисекунды
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InstrumentEncoder(
                          value: _seconds,
                          isInfinite:
                              true, // Вращается бесконечно, крутя минуты
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
                          value: _millis,
                          isInfinite:
                              true, // Вращается бесконечно, крутя секунды
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        FlightProgramStep(
          angle: _angle.toInt(),
          delaySec: _totalTimeMs ~/ 1000,
          delayMs: _totalTimeMs % 1000,
        ),
      );
    }
  }
}
