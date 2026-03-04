import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../../core/presentation/widgets/instrument_value.dart';
import '../../domain/entities/flight_program_step.dart';
import 'servo_visualizer.dart';

/// Виджет отображения шага полетной программы в списке.
class MissionStepCard extends StatelessWidget {
  final FlightProgramStep step;
  final int index;
  final dynamic strings;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const MissionStepCard({
    super.key,
    required this.step,
    required this.index,
    required this.strings,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InstrumentCard(
        label:
            '${strings.prog.stepNumber.toUpperCase()} ${(index + 1).toString().padLeft(2, '0')}',
        actions: [
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.close, size: 14, color: AppColors.error),
            visualDensity: VisualDensity.compact,
          ),
        ],
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              ServoVisualizer(angle: step.angle.value),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InstrumentValue(
                      value: '${step.angle.value}',
                      unit: strings.prog.unitDeg,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${strings.prog.delayBefore.toUpperCase()}: ${step.formattedDelay}',
                      style: AppTextStyles.instrumentLabel,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.edit, size: 16, color: AppColors.borderBright),
            ],
          ),
        ),
      ),
    );
  }
}
