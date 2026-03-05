import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/string_extensions.dart';
import 'instrument_encoder.dart';

/// Композитный виджет, объединяющий круговой энкодер и текстовое поле.
class TacticalEncoderField extends StatelessWidget {
  final double value;
  final double max;
  final String label;
  final String unit;
  final TextEditingController controller;
  final ValueChanged<double> onKnobChanged;
  final ValueChanged<String> onTextChanged;
  final bool isInfinite;

  const TacticalEncoderField({
    super.key,
    required this.value,
    required this.max,
    required this.label,
    required this.unit,
    required this.controller,
    required this.onKnobChanged,
    required this.onTextChanged,
    this.isInfinite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          InstrumentEncoder(
            value: value,
            min: 0,
            max: max,
            fullTurnValue: max,
            isInfinite: isInfinite,
            label: label.t,
            unit: unit,
            onChanged: onKnobChanged,
          ),
          const SizedBox(height: 8),
          _buildManualInput(),
        ],
      ),
    );
  }

  Widget _buildManualInput() {
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
        onChanged: onTextChanged,
      ),
    );
  }
}
