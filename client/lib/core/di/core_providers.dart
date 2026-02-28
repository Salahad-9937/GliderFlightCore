import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../network/http_network_client.dart';
import '../network/i_network_client.dart';
import '../services/datetime_service_impl.dart';
import '../services/i_datetime_service.dart';
import '../services/i_logger_service.dart';
import '../services/logger_service_impl.dart';
import '../constants/app_constants.dart';
import '../l10n/app_strings.dart';

/// Провайдер SharedPreferences.
/// Инициализируется через override в main.dart.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

/// Провайдер базового HTTP клиента.
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Провайдер логгера.
final loggerServiceProvider = Provider<ILoggerService>((ref) {
  return LoggerServiceImpl();
});

/// Провайдер службы времени.
final dateTimeServiceProvider = Provider<IDateTimeService>((ref) {
  return DateTimeServiceImpl();
});

/// Провайдер локализации.
final l10nProvider = Provider<AppStrings>((ref) {
  return AppStrings.ru;
});

/// Провайдер сетевого клиента для связи с планером.
final networkClientProvider = Provider<INetworkClient>((ref) {
  final client = ref.watch(httpClientProvider);
  return HttpNetworkClient(AppConstants.defaultDeviceIp, client);
});
