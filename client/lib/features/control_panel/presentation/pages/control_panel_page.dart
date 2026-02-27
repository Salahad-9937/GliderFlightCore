import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../../../glider_profiles/presentation/providers/glider_profiles_providers.dart';
import '../../../glider_profiles/presentation/widgets/edit_profile_dialog.dart';
import '../../../flight_programs/presentation/widgets/flight_programs_list.dart';

import '../../../device_communication/domain/entities/device_status.dart';
import '../../../device_communication/presentation/providers/device_connection_providers.dart';
import '../../../device_communication/presentation/providers/sensor_settings_controller.dart';
import '../../../device_communication/presentation/widgets/device_status_card.dart';
import '../../../device_communication/presentation/widgets/system_health_card.dart';

import '../widgets/flight_history_section.dart';

/// Страница управления планером.
///
/// Выступает в роли композиционного узла, объединяя виджеты телеметрии,
/// программ и истории для конкретного профиля.
class ControlPanelPage extends ConsumerStatefulWidget {
  final String gliderProfileId;
  const ControlPanelPage({super.key, required this.gliderProfileId});

  @override
  ConsumerState<ControlPanelPage> createState() => _ControlPanelPageState();
}

class _ControlPanelPageState extends ConsumerState<ControlPanelPage>
    with WidgetsBindingObserver {
  late DeviceConnectionNotifier _connectionNotifier;
  late SensorSettingsController _settingsController;
  bool _isBackgrounded = false;

  @override
  void initState() {
    super.initState();
    _connectionNotifier = ref.read(deviceConnectionNotifierProvider.notifier);
    _settingsController = ref.read(sensorSettingsControllerProvider);
    WidgetsBinding.instance.addObserver(this);

    // Инициируем подключение при входе на страницу
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectionNotifier.connect();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Полный разрыв сессии при уходе со страницы
    _connectionNotifier.disconnect();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final device = ref.read(deviceConnectionNotifierProvider);
    if (device.status != DeviceStatus.connected) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (!_isBackgrounded) {
        _isBackgrounded = true;
        _connectionNotifier.pausePolling();
        _settingsController.toggleMonitoring(false);
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_isBackgrounded) {
        _isBackgrounded = false;
        _settingsController.toggleMonitoring(true).then((_) {
          _connectionNotifier.resumePolling();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileByIdProvider(widget.gliderProfileId));
    final strings = ref.watch(l10nProvider);

    if (profile == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(strings.profileNotFound)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(profile.name),
        actions: [
          IconButton(
            onPressed: () => showEditProfileDialog(
              context,
              ref,
              widget.gliderProfileId,
              profile.name,
            ),
            icon: const Icon(Icons.edit_outlined),
            tooltip: strings.renameGlider,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Основная телеметрия
          DeviceStatusCard(profileId: widget.gliderProfileId),
          const SizedBox(height: 16),

          // Системная диагностика
          SystemHealthCard(profileId: widget.gliderProfileId),

          const SizedBox(height: 24),

          // Список полетных программ
          FlightProgramsList(profileId: widget.gliderProfileId),

          const SizedBox(height: 24),

          // Секция истории полетов
          const FlightHistorySection(),
        ],
      ),
    );
  }
}
