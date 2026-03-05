import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../providers/glider_profiles_providers.dart';
import '../widgets/add_profile_dialog.dart';
import '../widgets/glider_profile_card.dart';
import '../widgets/glider_profiles_app_bar.dart';
import '../widgets/profiles_empty_state.dart';

/// Страница списка планеров в стиле "Ангар бортового компьютера".
class GliderProfilesPage extends ConsumerWidget {
  const GliderProfilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(gliderProfilesProvider);
    final strings = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const GliderProfilesAppBar(),
      body: SafeArea(
        child: profilesAsync.when(
          data: (profiles) => profiles.isEmpty
              ? ProfilesEmptyState(strings: strings.profiles)
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: GliderProfileCard(
                      profile: profiles[index],
                      index: index + 1,
                    ),
                  ),
                ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Text(
              '${strings.core.systemErrorPrefix.t}: $err',
              style: AppTextStyles.instrumentLabel.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddProfileDialog(context, ref),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: const Icon(Icons.add_box_outlined),
      ),
    );
  }
}
