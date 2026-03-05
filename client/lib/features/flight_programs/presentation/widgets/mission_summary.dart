import 'package:flutter/material.dart';
import '../../../../core/presentation/widgets/instrument_value.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/flight_program.dart';

/// Виджет сводной информации о программе в редакторе.
class MissionSummary extends StatelessWidget {
  final FlightProgram program;
  final bool hasChanges;
  final dynamic strings;

  const MissionSummary({
    super.key,
    required this.program,
    required this.hasChanges,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.prog.totalMissionTime.t,
                style: AppTextStyles.instrumentLabel,
              ),
              InstrumentValue(
                value: program.formattedTotalDuration,
                unit: strings.prog.unitSecShort.t,
                valueStyle: AppTextStyles.telemetryValueMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                strings.prog.sequenceStatus.t,
                style: AppTextStyles.instrumentLabel,
              ),
              Text(
                (hasChanges ? strings.prog.modified : strings.prog.synced).t,
                style: AppTextStyles.button.copyWith(
                  color: hasChanges ? AppColors.warning : AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
