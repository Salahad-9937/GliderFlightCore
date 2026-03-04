// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_program_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер реализации репозитория полетных программ.

@ProviderFor(flightProgramRepository)
final flightProgramRepositoryProvider = FlightProgramRepositoryProvider._();

/// Провайдер реализации репозитория полетных программ.

final class FlightProgramRepositoryProvider
    extends
        $FunctionalProvider<
          IFlightProgramRepository,
          IFlightProgramRepository,
          IFlightProgramRepository
        >
    with $Provider<IFlightProgramRepository> {
  /// Провайдер реализации репозитория полетных программ.
  FlightProgramRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'flightProgramRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$flightProgramRepositoryHash();

  @$internal
  @override
  $ProviderElement<IFlightProgramRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IFlightProgramRepository create(Ref ref) {
    return flightProgramRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IFlightProgramRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IFlightProgramRepository>(value),
    );
  }
}

String _$flightProgramRepositoryHash() =>
    r'63f7a2db1520702136061e02a6e4050fff49b8eb';
