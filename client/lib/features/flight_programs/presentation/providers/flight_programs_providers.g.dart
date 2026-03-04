// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_programs_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер управления списком программ.

@ProviderFor(FlightPrograms)
final flightProgramsProvider = FlightProgramsFamily._();

/// Провайдер управления списком программ.
final class FlightProgramsProvider
    extends $AsyncNotifierProvider<FlightPrograms, List<FlightProgram>> {
  /// Провайдер управления списком программ.
  FlightProgramsProvider._({
    required FlightProgramsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'flightProgramsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$flightProgramsHash();

  @override
  String toString() {
    return r'flightProgramsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FlightPrograms create() => FlightPrograms();

  @override
  bool operator ==(Object other) {
    return other is FlightProgramsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$flightProgramsHash() => r'07fd51cf2bb12bc54d190deed44c15bc1153d8ef';

/// Провайдер управления списком программ.

final class FlightProgramsFamily extends $Family
    with
        $ClassFamilyOverride<
          FlightPrograms,
          AsyncValue<List<FlightProgram>>,
          List<FlightProgram>,
          FutureOr<List<FlightProgram>>,
          String
        > {
  FlightProgramsFamily._()
    : super(
        retry: null,
        name: r'flightProgramsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Провайдер управления списком программ.

  FlightProgramsProvider call(String profileId) =>
      FlightProgramsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'flightProgramsProvider';
}

/// Провайдер управления списком программ.

abstract class _$FlightPrograms extends $AsyncNotifier<List<FlightProgram>> {
  late final _$args = ref.$arg as String;
  String get profileId => _$args;

  FutureOr<List<FlightProgram>> build(String profileId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<FlightProgram>>, List<FlightProgram>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FlightProgram>>, List<FlightProgram>>,
              AsyncValue<List<FlightProgram>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Провайдер для получения одной программы по ID.

@ProviderFor(programById)
final programByIdProvider = ProgramByIdFamily._();

/// Провайдер для получения одной программы по ID.

final class ProgramByIdProvider
    extends $FunctionalProvider<FlightProgram?, FlightProgram?, FlightProgram?>
    with $Provider<FlightProgram?> {
  /// Провайдер для получения одной программы по ID.
  ProgramByIdProvider._({
    required ProgramByIdFamily super.from,
    required ({String profileId, String programId}) super.argument,
  }) : super(
         retry: null,
         name: r'programByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$programByIdHash();

  @override
  String toString() {
    return r'programByIdProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<FlightProgram?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FlightProgram? create(Ref ref) {
    final argument = this.argument as ({String profileId, String programId});
    return programById(
      ref,
      profileId: argument.profileId,
      programId: argument.programId,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlightProgram? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlightProgram?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProgramByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$programByIdHash() => r'b528327051eeb5b86f5e5ce270c1c9b2eac512d5';

/// Провайдер для получения одной программы по ID.

final class ProgramByIdFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FlightProgram?,
          ({String profileId, String programId})
        > {
  ProgramByIdFamily._()
    : super(
        retry: null,
        name: r'programByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Провайдер для получения одной программы по ID.

  ProgramByIdProvider call({
    required String profileId,
    required String programId,
  }) => ProgramByIdProvider._(
    argument: (profileId: profileId, programId: programId),
    from: this,
  );

  @override
  String toString() => r'programByIdProvider';
}
