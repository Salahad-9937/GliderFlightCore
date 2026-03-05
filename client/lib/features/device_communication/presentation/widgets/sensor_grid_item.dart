import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/instrument_value.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';

/// Виджет для отображения отдельного параметра датчика.
class SensorGridItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color? color;

  const SensorGridItem({
    super.key,
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color ?? Colors.grey),
            const SizedBox(width: 4),
            InstrumentValue(value: value, unit: unit, color: color),
          ],
        ),
        const SizedBox(height: 4),
        Text(label.t, style: AppTextStyles.instrumentLabel),
      ],
    );
  }
}
