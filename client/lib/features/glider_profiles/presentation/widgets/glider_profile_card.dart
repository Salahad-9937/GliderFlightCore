import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/presentation/widgets/instrument_card.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../control_panel/presentation/pages/control_panel_page.dart';
import '../../domain/entities/glider_profile.dart';
import 'delete_profile_dialog.dart';

/// Виджет карточки планера в списке ангара.
class GliderProfileCard extends ConsumerWidget {
  final GliderProfile profile;
  final int index;

  const GliderProfileCard({
    super.key,
    required this.profile,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);

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
                    strings.core.delete.t,
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
            _Avatar(label: profile.avatarLabel),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name.t,
                    style: AppTextStyles.sectionTitle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${strings.panel.idLabel.t}: ${profile.shortId}',
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

class _Avatar extends StatelessWidget {
  final String label;
  const _Avatar({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTextStyles.telemetryValueMedium.copyWith(
            color: AppColors.primary,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}
