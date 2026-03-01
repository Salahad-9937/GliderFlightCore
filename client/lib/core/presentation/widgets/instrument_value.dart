import 'package:flutter/material.dart';
import '../../theme/app_text_styles.dart';

/// Виджет для отображения числовых данных с единицей измерения.
class InstrumentValue extends StatelessWidget {
  final String value;
  final String unit;
  final TextStyle? valueStyle;
  final Color? color;

  const InstrumentValue({
    super.key,
    required this.value,
    required this.unit,
    this.valueStyle,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: (valueStyle ?? AppTextStyles.telemetryValueMedium).copyWith(
            color: color ?? Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          unit,
          style: AppTextStyles.instrumentLabel.copyWith(
            fontSize: (valueStyle?.fontSize ?? 24) * 0.4,
          ),
        ),
      ],
    );
  }
}
