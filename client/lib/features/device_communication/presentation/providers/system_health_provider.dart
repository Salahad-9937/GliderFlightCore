import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/entities/system_health.dart';
import 'device_connection_providers.dart';
import 'device_usecase_providers.dart';

/// Провайдер данных системной диагностики.
///
/// Обновляется только при изменении статуса подключения.
final systemHealthProvider = FutureProvider.family<SystemHealth?, String>((
  ref,
  profileId,
) async {
  final connectionStatus = ref.watch(
    deviceConnectionNotifierProvider.select((s) => s.status),
  );

  if (connectionStatus != DeviceStatus.connected) return null;

  final result = await ref
      .read(getSystemHealthUseCaseProvider)
      .call(const NoParams());

  return result.fold(
    (health) => health,
    (failure) => throw Exception(failure.message),
  );
});

/// Провайдер таймера для UI (время с момента последнего обновления).
final systemUpdateTimerProvider = StreamProvider.autoDispose((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});
