import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/http_network_client.dart';
import '../network/i_network_client.dart';
import '../services/datetime_service_impl.dart';
import '../services/i_datetime_service.dart';
import '../services/i_logger_service.dart';
import '../services/logger_service_impl.dart';
import '../constants/app_constants.dart';
import '../l10n/app_strings.dart';

part 'core_providers.g.dart';

/// Провайдер SharedPreferences.
/// Инициализируется через override в main.dart.
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError();
}

/// Провайдер базового HTTP клиента.
@Riverpod(keepAlive: true)
http.Client httpClient(Ref ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
}

/// Провайдер логгера.
@Riverpod(keepAlive: true)
ILoggerService loggerService(Ref ref) {
  return LoggerServiceImpl();
}

/// Провайдер службы времени.
@Riverpod(keepAlive: true)
IDateTimeService dateTimeService(Ref ref) {
  return DateTimeServiceImpl();
}

/// Провайдер локализации.
@Riverpod(keepAlive: true)
AppStrings l10n(Ref ref) {
  return AppStrings.ru;
}

/// Провайдер сетевого клиента для связи с планером.
@Riverpod(keepAlive: true)
INetworkClient networkClient(Ref ref) {
  final client = ref.watch(httpClientProvider);
  return HttpNetworkClient(AppConstants.defaultDeviceIp, client);
}
