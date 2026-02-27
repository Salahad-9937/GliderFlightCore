import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/i_logger_service.dart';

/// Наблюдатель за всеми изменениями состояний в приложении.
///
/// В Riverpod 3.x класс должен быть final, base или sealed.
final class AppProviderObserver extends ProviderObserver {
  final ILoggerService _logger;

  AppProviderObserver(this._logger);

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    final name = context.provider.name ?? context.provider.runtimeType;
    _logger.d('Provider $name updated');
  }

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final name = context.provider.name ?? context.provider.runtimeType;
    _logger.e('Provider $name failed', error, stackTrace);
  }
}
