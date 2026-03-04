import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/architecture/use_case.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/entities/system_health.dart';
import 'device_connection_providers.dart';
import 'device_usecase_providers.dart';

part 'system_health_provider.g.dart';

/// Провайдер данных системной диагностики.
@riverpod
Future<SystemHealth?> systemHealth(Ref ref, String profileId) async {
  // Обновлена ссылка на провайдер
  final connectionStatus = ref.watch(
    deviceConnectionProvider.select((s) => s.status),
  );

  if (connectionStatus != DeviceStatus.connected) return null;

  final result = await ref
      .read(getSystemHealthUseCaseProvider)
      .call(const NoParams());

  return result.fold(
    (health) => health,
    (failure) => throw Exception(failure.message),
  );
}

/// Провайдер таймера для UI.
@riverpod
Stream<int> systemUpdateTimer(Ref ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
}
