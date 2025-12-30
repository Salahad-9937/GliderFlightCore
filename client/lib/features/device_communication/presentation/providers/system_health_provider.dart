import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/system_health.dart';
import '../../data/repositories/device_repository_impl.dart';
import 'device_connection_providers.dart';
import '../../domain/entities/device_status.dart';

/// Провайдер для получения данных системной диагностики.
final systemHealthProvider = FutureProvider.family<SystemHealth?, String>((ref, profileId) async {
  // КРИТИЧЕСКОЕ ИСПРАВЛЕНИЕ: Используем select, чтобы следить ТОЛЬКО за статусом.
  // Теперь провайдер НЕ будет перезапускаться при изменении высоты или давления.
  final connectionStatus = ref.watch(
    deviceConnectionNotifierProvider.select((s) => s.status)
  );
  
  if (connectionStatus != DeviceStatus.connected) {
    return null;
  }

  // IP адрес берем через read, так как он не меняется в процессе сессии
  final ipAddress = ref.read(deviceConnectionNotifierProvider).ipAddress;
  if (ipAddress == null) return null;
  
  final repository = ref.read(deviceRepositoryProvider);
  
  // Делаем запрос
  return await repository.getSystemHealth(ipAddress);
});

/// Провайдер для текстового счетчика "Прошло времени"
final systemUpdateTimerProvider = StreamProvider.autoDispose((ref) {
  return Stream.periodic(const Duration(seconds: 1), (i) => i);
});