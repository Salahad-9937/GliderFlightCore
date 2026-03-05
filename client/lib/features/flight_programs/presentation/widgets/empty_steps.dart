import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Виджет, отображаемый в редакторе, если шаги миссии не заданы.
class EmptySteps extends StatelessWidget {
  /// Локализованные строки.
  final dynamic strings;

  const EmptySteps({super.key, required this.strings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        strings.prog.noMissionSteps.t,
        style: AppTextStyles.instrumentLabel.copyWith(
          color: AppColors.borderBright,
        ),
      ),
    );
  }
}
