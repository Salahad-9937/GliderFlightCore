import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../glider_profiles/presentation/providers/glider_profiles_providers.dart';
import '../../../device_communication/presentation/providers/device_connection_providers.dart';

import '../widgets/control_panel_app_bar.dart';
import '../widgets/views/terminal_view.dart';
import '../widgets/views/missions_view.dart';
import '../widgets/views/logs_view.dart';

/// Страница управления планером с нижней навигацией без подписей.
class ControlPanelPage extends ConsumerStatefulWidget {
  final String gliderProfileId;

  const ControlPanelPage({super.key, required this.gliderProfileId});

  @override
  ConsumerState<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends ConsumerState<ControlPanelPage>
    with WidgetsBindingObserver {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    ref.read(deviceConnectionProvider.notifier).handleLifecycleChange(state);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileByIdProvider(widget.gliderProfileId));

    if (profile == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            'PROFILE_NOT_FOUND',
            style: AppTextStyles.instrumentLabel,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ControlPanelAppBar(profile: profile),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            TerminalView(profileId: widget.gliderProfileId),
            MissionsView(profileId: widget.gliderProfileId),
            const LogsView(),
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.borderBright,
          // Отключение подписей для экономии места
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sensors_outlined),
              activeIcon: Icon(Icons.sensors),
              label: '', // Пустая строка обязательна для API
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.developer_board_outlined),
              activeIcon: Icon(Icons.developer_board),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.data_exploration_outlined),
              activeIcon: Icon(Icons.data_exploration),
              label: '',
            ),
          ],
        ),
      ),
    );
  }
}
