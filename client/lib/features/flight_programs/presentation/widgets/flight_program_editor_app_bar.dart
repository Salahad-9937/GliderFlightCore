import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../domain/entities/flight_program.dart';

/// Специализированный AppBar для экрана редактирования полетной последовательности.
class FlightProgramEditorAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// Текущая программа.
  final FlightProgram program;

  /// Флаг наличия несохраненных изменений.
  final bool hasChanges;

  /// Колбэк сохранения.
  final VoidCallback onSave;

  const FlightProgramEditorAppBar({
    super.key,
    required this.program,
    required this.hasChanges,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(program.name.t, style: AppTextStyles.sectionTitle),
          Text(
            'MISSION SEQUENCE EDITOR'.t,
            style: AppTextStyles.instrumentLabel,
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onSave,
          icon: Icon(
            Icons.save,
            color: hasChanges ? AppColors.warning : AppColors.primary,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
