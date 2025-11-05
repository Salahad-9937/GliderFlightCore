import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/glider_profile.dart';
import '../providers/glider_profiles_providers.dart';
import '../widgets/add_profile_dialog.dart';
// Импортируем новый виджет диалога
import '../widgets/delete_profile_dialog.dart';

/// Главный экран приложения, отображающий список профилей планеров.
class GliderProfilesPage extends ConsumerWidget {
  const GliderProfilesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsyncValue = ref.watch(gliderProfilesNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои планеры'),
      ),
      body: profilesAsyncValue.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return _GliderProfileCard(profile: profile);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Ошибка: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddProfileDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Виджет-карточка для отображения одного профиля планера.
class _GliderProfileCard extends ConsumerWidget {
  const _GliderProfileCard({required this.profile});
  final GliderProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Убрали Dismissible, оставили только Card
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 20, right: 8, top: 10, bottom: 10),
        leading: CircleAvatar(
          radius: 24,
          child: Text(profile.name.isNotEmpty ? profile.name[0].toUpperCase() : ''),
        ),
        title: Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
        // При нажатии на ListTile происходит переход на следующий экран
        onTap: () {
          // TODO: Переход на "Панель управления планером"
        },
        // Добавляем меню с опциями для карточки
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              showDeleteProfileDialog(context, ref, profile);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Удалить'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/// Виджет для отображения пустого состояния, когда нет профилей.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.airplanemode_inactive_outlined, size: 80, color: Colors.grey.shade700),
          const SizedBox(height: 16),
          Text(
            'Нет добавленных планеров',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Нажмите "+", чтобы создать первый профиль',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}