// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glider_profile_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер реализации репозитория профилей.

@ProviderFor(gliderProfileRepository)
final gliderProfileRepositoryProvider = GliderProfileRepositoryProvider._();

/// Провайдер реализации репозитория профилей.

final class GliderProfileRepositoryProvider
    extends
        $FunctionalProvider<
          IGliderProfileRepository,
          IGliderProfileRepository,
          IGliderProfileRepository
        >
    with $Provider<IGliderProfileRepository> {
  /// Провайдер реализации репозитория профилей.
  GliderProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'gliderProfileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$gliderProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<IGliderProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IGliderProfileRepository create(Ref ref) {
    return gliderProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IGliderProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IGliderProfileRepository>(value),
    );
  }
}

String _$gliderProfileRepositoryHash() =>
    r'20dc3779aecec0181d9360d52748423dc60d4f70';
