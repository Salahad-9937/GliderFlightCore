import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../glider_profiles/presentation/providers/glider_profiles_providers.dart';
import '../../../flight_programs/presentation/widgets/flight_programs_list.dart';
import '../../../device_communication/presentation/providers/device_connection_providers.dart';
import '../../../device_communication/presentation/widgets/device_status_card.dart';
import '../../../device_communication/presentation/widgets/system_health_card.dart';

import '../widgets/control_panel_app_bar.dart';
import '../widgets/flight_history_section.dart';

/// Страница управления миссией.
/// Логика инициализации и очистки связи теперь инкапсулирована в провайдере.
class ControlPanelPage extends ConsumerStatefulWidget {
  final String gliderProfileId;
  const ControlPanelPage({super.key, required this.gliderProfileId});

  @override
  ConsumerState<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends ConsumerState<ControlPanelPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Больше не вызываем connect() вручную, провайдер сам поймет, что его начали слушать.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Больше не вызываем disconnect() вручную. При закрытии страницы
    // слушатели пропадут, и autoDispose провайдер сам остановит поллинг.
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    // Оставляем только реакцию на сворачивание приложения (экономия батареи)
    ref.read(deviceConnectionProvider.notifier).handleLifecycleChange(state);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileByIdProvider(widget.gliderProfileId));
    final strings = ref.watch(l10nProvider);

    if (profile == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Text(
            strings.panel.profileNotFound.t,
            style: AppTextStyles.instrumentLabel,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: ControlPanelAppBar(profile: profile),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          children: [
            DeviceStatusCard(profileId: widget.gliderProfileId),
            const SizedBox(height: 16),
            SystemHealthCard(profileId: widget.gliderProfileId),
            const SizedBox(height: 24),
            FlightProgramsList(profileId: widget.gliderProfileId),
            const SizedBox(height: 24),
            const FlightHistorySection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
