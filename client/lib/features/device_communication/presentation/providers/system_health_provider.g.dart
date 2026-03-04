// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_health_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер данных системной диагностики.

@ProviderFor(systemHealth)
final systemHealthProvider = SystemHealthFamily._();

/// Провайдер данных системной диагностики.

final class SystemHealthProvider
    extends
        $FunctionalProvider<
          AsyncValue<SystemHealth?>,
          SystemHealth?,
          FutureOr<SystemHealth?>
        >
    with $FutureModifier<SystemHealth?>, $FutureProvider<SystemHealth?> {
  /// Провайдер данных системной диагностики.
  SystemHealthProvider._({
    required SystemHealthFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'systemHealthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$systemHealthHash();

  @override
  String toString() {
    return r'systemHealthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<SystemHealth?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SystemHealth?> create(Ref ref) {
    final argument = this.argument as String;
    return systemHealth(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SystemHealthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$systemHealthHash() => r'f6bc3d9cf3ce65ba77af69b672383df1501c5f4b';

/// Провайдер данных системной диагностики.

final class SystemHealthFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<SystemHealth?>, String> {
  SystemHealthFamily._()
    : super(
        retry: null,
        name: r'systemHealthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Провайдер данных системной диагностики.

  SystemHealthProvider call(String profileId) =>
      SystemHealthProvider._(argument: profileId, from: this);

  @override
  String toString() => r'systemHealthProvider';
}

/// Провайдер таймера для UI.

@ProviderFor(systemUpdateTimer)
final systemUpdateTimerProvider = SystemUpdateTimerProvider._();

/// Провайдер таймера для UI.

final class SystemUpdateTimerProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// Провайдер таймера для UI.
  SystemUpdateTimerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'systemUpdateTimerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$systemUpdateTimerHash();

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    return systemUpdateTimer(ref);
  }
}

String _$systemUpdateTimerHash() => r'4106446e841118acf747b73742ca75eeb32d3313';
