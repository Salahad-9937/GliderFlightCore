import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../control_panel/presentation/pages/control_panel_page.dart';
import '../../domain/entities/glider_profile.dart';
import '../providers/glider_profiles_providers.dart';
import '../widgets/add_profile_dialog.dart';
import '../widgets/delete_profile_dialog.dart';

class GliderProfilesPage extends ConsumerWidget {
  const GliderProfilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(gliderProfilesNotifierProvider);
    final strings = ref.watch(l10nProvider);

    return Scaffold(
      appBar: AppBar(title: Text(strings.profiles.myGliders)),
      body: profilesAsync.when(
        data: (profiles) => profiles.isEmpty
            ? _EmptyState(strings: strings.profiles)
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: profiles.length,
                itemBuilder: (context, index) =>
                    _GliderProfileCard(profile: profiles[index]),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('${strings.core.error}: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddProfileDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GliderProfileCard extends ConsumerWidget {
  final GliderProfile profile;
  const _GliderProfileCard({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(l10nProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          child: Text(
            profile.name.isNotEmpty ? profile.name[0].toUpperCase() : '?',
          ),
        ),
        title: Text(
          profile.name,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ControlPanelPage(gliderProfileId: profile.id),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              showDeleteProfileDialog(context, ref, profile);
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(strings.core.delete),
                contentPadding: EdgeInsets.zero,
              ),
            ),
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
          Icon(
            Icons.airplanemode_inactive_outlined,
            size: 80,
            color: Colors.grey.shade700,
          ),
          const SizedBox(height: 16),
          Text(
            strings.noGliders,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            strings.addFirstProfile,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
