import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../glider_profiles/domain/entities/glider_profile.dart';
import '../../../glider_profiles/presentation/widgets/edit_profile_dialog.dart';

/// Специализированный AppBar для страницы управления миссией.
class ControlPanelAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final GliderProfile profile;

  const ControlPanelAppBar({super.key, required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);

    return AppBar(
      backgroundColor: AppColors.background,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(profile.name.t, style: AppTextStyles.sectionTitle),
          Text('MISSION CONTROL'.t, style: AppTextStyles.instrumentLabel),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () =>
              showEditProfileDialog(context, ref, profile.id, profile.name),
          icon: const Icon(Icons.edit_note, color: AppColors.primary),
          tooltip: strings.panel.renameGlider,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
