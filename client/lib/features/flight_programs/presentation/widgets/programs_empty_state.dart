import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Виджет, отображаемый при отсутствии программ в списке профиля.
class ProgramsEmptyState extends StatelessWidget {
  /// Локализованные строки.
  final dynamic strings;

  const ProgramsEmptyState({super.key, required this.strings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          const Icon(Icons.layers_clear, color: AppColors.border, size: 20),
          const SizedBox(width: 12),
          Text(strings.noPrograms.t, style: AppTextStyles.instrumentLabel),
        ],
      ),
    );
  }
}
