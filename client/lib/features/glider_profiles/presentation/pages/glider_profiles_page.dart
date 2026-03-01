import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../control_panel/presentation/pages/control_panel_page.dart';
import '../../domain/entities/glider_profile.dart';
import '../providers/glider_profiles_providers.dart';
import '../widgets/add_profile_dialog.dart';
import '../widgets/delete_profile_dialog.dart';

/// Страница списка планеров в стиле "Ангар бортового компьютера".
class GliderProfilesPage extends ConsumerWidget {
  const GliderProfilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(gliderProfilesNotifierProvider);
    final strings = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.profiles.myGliders.toUpperCase(),
              style: AppTextStyles.sectionTitle,
            ),
            Text(
              strings.panel.hangarManagement,
              style: AppTextStyles.instrumentLabel,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: profilesAsync.when(
          data: (profiles) => profiles.isEmpty
              ? _EmptyState(strings: strings.profiles)
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: profiles.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _GliderProfileCard(
                      profile: profiles[index],
                      index: index + 1,
                      strings: strings,
                    ),
                  ),
                ),
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Text(
              '${strings.core.systemErrorPrefix}: $err'.toUpperCase(),
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

class _GliderProfileCard extends ConsumerWidget {
  final GliderProfile profile;
  final int index;
  final dynamic strings;

  const _GliderProfileCard({
    required this.profile,
    required this.index,
    required this.strings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InstrumentCard(
      label: '${strings.panel.slot} ${index.toString().padLeft(2, '0')}',
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, size: 18, color: AppColors.primary),
          onSelected: (value) {
            if (value == 'delete') {
              showDeleteProfileDialog(context, ref, profile);
            }
          },
          color: AppColors.surfaceLight,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    strings.core.delete.toUpperCase(),
                    style: AppTextStyles.instrumentLabel.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ControlPanelPage(gliderProfileId: profile.id),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
                  style: AppTextStyles.telemetryValueMedium.copyWith(
                    color: AppColors.primary,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name.toUpperCase(),
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${strings.panel.idLabel}: ${profile.id.substring(0, 8).toUpperCase()}',
                    style: AppTextStyles.instrumentLabel.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.borderBright),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final dynamic strings;
  const _EmptyState({required this.strings});

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
          Text(
            strings.noGliders.toUpperCase(),
            style: AppTextStyles.instrumentLabel,
          ),
          const SizedBox(height: 8),
          Text(
            strings.addFirstProfile.toUpperCase(),
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
