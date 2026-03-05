import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';

/// Специализированный AppBar для страницы ангара.
class GliderProfilesAppBar extends ConsumerWidget
    implements PreferredSizeWidget {
  const GliderProfilesAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);

    return AppBar(
      backgroundColor: AppColors.background,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.profiles.myGliders.t, style: AppTextStyles.sectionTitle),
          Text(
            strings.panel.hangarManagement.t,
            style: AppTextStyles.instrumentLabel,
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
