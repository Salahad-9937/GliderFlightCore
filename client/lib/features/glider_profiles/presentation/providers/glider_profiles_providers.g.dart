// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glider_profiles_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Управление списком профилей через UseCases.

@ProviderFor(GliderProfiles)
final gliderProfilesProvider = GliderProfilesProvider._();

/// Управление списком профилей через UseCases.
final class GliderProfilesProvider
    extends $AsyncNotifierProvider<GliderProfiles, List<GliderProfile>> {
  /// Управление списком профилей через UseCases.
  GliderProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gliderProfilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gliderProfilesHash();

  @$internal
  @override
  GliderProfiles create() => GliderProfiles();
}

String _$gliderProfilesHash() => r'a6a086489e691f997441e1ab23b99cbfcdf5acdc';

/// Управление списком профилей через UseCases.

abstract class _$GliderProfiles extends $AsyncNotifier<List<GliderProfile>> {
  FutureOr<List<GliderProfile>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<GliderProfile>>, List<GliderProfile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<GliderProfile>>, List<GliderProfile>>,
              AsyncValue<List<GliderProfile>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Провайдер для получения профиля по ID.

@ProviderFor(profileById)
final profileByIdProvider = ProfileByIdFamily._();

/// Провайдер для получения профиля по ID.

final class ProfileByIdProvider
    extends $FunctionalProvider<GliderProfile?, GliderProfile?, GliderProfile?>
    with $Provider<GliderProfile?> {
  /// Провайдер для получения профиля по ID.
  ProfileByIdProvider._({
    required ProfileByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileByIdHash();

  @override
  String toString() {
    return r'profileByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<GliderProfile?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GliderProfile? create(Ref ref) {
    final argument = this.argument as String;
    return profileById(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GliderProfile? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GliderProfile?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileByIdHash() => r'ccf0882e6327c435780a8e884fe88e1b3ef61f7c';

/// Провайдер для получения профиля по ID.

final class ProfileByIdFamily extends $Family
    with $FunctionalFamilyOverride<GliderProfile?, String> {
  ProfileByIdFamily._()
    : super(
        retry: null,
        name: r'profileByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Провайдер для получения профиля по ID.

  ProfileByIdProvider call(String id) =>
      ProfileByIdProvider._(argument: id, from: this);

  @override
  String toString() => r'profileByIdProvider';
}
