import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/l10n/parts/profile_strings.dart';

/// Виджет, отображаемый при отсутствии профилей в ангаре.
class ProfilesEmptyState extends StatelessWidget {
  final ProfileStrings strings;
  const ProfilesEmptyState({super.key, required this.strings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.airplanemode_inactive,
            size: 64,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(strings.noGliders.t, style: AppTextStyles.instrumentLabel),
          const SizedBox(height: 8),
          Text(
            strings.addFirstProfile.t,
            style: AppTextStyles.instrumentLabel.copyWith(
              color: AppColors.borderBright,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
