// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер SharedPreferences.
/// Инициализируется через override в main.dart.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Провайдер SharedPreferences.
/// Инициализируется через override в main.dart.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Провайдер SharedPreferences.
  /// Инициализируется через override в main.dart.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'1a6250efdc19e86c923ceb598a77ff74d64378e6';

/// Провайдер базового HTTP клиента.

@ProviderFor(httpClient)
final httpClientProvider = HttpClientProvider._();

/// Провайдер базового HTTP клиента.

final class HttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  /// Провайдер базового HTTP клиента.
  HttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'httpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$httpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return httpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$httpClientHash() => r'7ec49beae0f15115de79f9aa98dbd250130e26d8';

/// Провайдер логгера.

@ProviderFor(loggerService)
final loggerServiceProvider = LoggerServiceProvider._();

/// Провайдер логгера.

final class LoggerServiceProvider
    extends $FunctionalProvider<ILoggerService, ILoggerService, ILoggerService>
    with $Provider<ILoggerService> {
  /// Провайдер логгера.
  LoggerServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loggerServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loggerServiceHash();

  @$internal
  @override
  $ProviderElement<ILoggerService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ILoggerService create(Ref ref) {
    return loggerService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ILoggerService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ILoggerService>(value),
    );
  }
}

String _$loggerServiceHash() => r'2ce0d86558869051cacc3696699aa6317f2a7526';

/// Провайдер службы времени.

@ProviderFor(dateTimeService)
final dateTimeServiceProvider = DateTimeServiceProvider._();

/// Провайдер службы времени.

final class DateTimeServiceProvider
    extends
        $FunctionalProvider<
          IDateTimeService,
          IDateTimeService,
          IDateTimeService
        >
    with $Provider<IDateTimeService> {
  /// Провайдер службы времени.
  DateTimeServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dateTimeServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dateTimeServiceHash();

  @$internal
  @override
  $ProviderElement<IDateTimeService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IDateTimeService create(Ref ref) {
    return dateTimeService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IDateTimeService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IDateTimeService>(value),
    );
  }
}

String _$dateTimeServiceHash() => r'67a06092726221c5a760e74059e5ac9b855488c7';

/// Провайдер локализации.

@ProviderFor(l10n)
final l10nProvider = L10nProvider._();

/// Провайдер локализации.

final class L10nProvider
    extends $FunctionalProvider<AppStrings, AppStrings, AppStrings>
    with $Provider<AppStrings> {
  /// Провайдер локализации.
  L10nProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'l10nProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$l10nHash();

  @$internal
  @override
  $ProviderElement<AppStrings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppStrings create(Ref ref) {
    return l10n(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppStrings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppStrings>(value),
    );
  }
}

String _$l10nHash() => r'a6533a893c021dea8fdacc8cc07bb22ef373f006';

/// Провайдер сетевого клиента для связи с планером.

@ProviderFor(networkClient)
final networkClientProvider = NetworkClientProvider._();

/// Провайдер сетевого клиента для связи с планером.

final class NetworkClientProvider
    extends $FunctionalProvider<INetworkClient, INetworkClient, INetworkClient>
    with $Provider<INetworkClient> {
  /// Провайдер сетевого клиента для связи с планером.
  NetworkClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkClientHash();

  @$internal
  @override
  $ProviderElement<INetworkClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  INetworkClient create(Ref ref) {
    return networkClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(INetworkClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<INetworkClient>(value),
    );
  }
}

String _$networkClientHash() => r'5fd9d12f7732506d2a28defed0a14003630ef245';
