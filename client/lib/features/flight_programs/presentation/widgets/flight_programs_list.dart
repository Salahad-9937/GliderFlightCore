import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../providers/flight_programs_providers.dart';
import 'flight_program_dialogs.dart';
import 'program_card.dart';
import 'programs_empty_state.dart';

class FlightProgramsList extends ConsumerWidget {
  final String profileId;
  const FlightProgramsList({super.key, required this.profileId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(flightProgramsProvider(profileId));
    final strings = ref.watch(l10nProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              strings.prog.programsTitle.t,
              style: AppTextStyles.sectionTitle,
            ),
            IconButton(
              onPressed: () =>
                  FlightProgramDialogs.showAdd(context, ref, profileId),
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
                size: 20,
              ),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 12),
        programsAsync.when(
          data: (programs) => programs.isEmpty
              ? ProgramsEmptyState(strings: strings.prog)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: programs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) => ProgramCard(
                    profileId: profileId,
                    program: programs[index],
                    index: index + 1,
                  ),
                ),
          loading: () => const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
          ),
          error: (e, _) => Text(
            '${strings.core.systemErrorPrefix.t}: $e',
            style: AppTextStyles.instrumentLabel.copyWith(
              color: AppColors.error,
            ),
          ),
        ),
      ],
    );
  }
}
