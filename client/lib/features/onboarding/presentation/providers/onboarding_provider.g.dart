// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Контроллер процесса приветствия.
///
/// Использует [keepAlive: true], чтобы состояние сохранялось в течение всей сессии.

@ProviderFor(Onboarding)
final onboardingProvider = OnboardingProvider._();

/// Контроллер процесса приветствия.
///
/// Использует [keepAlive: true], чтобы состояние сохранялось в течение всей сессии.
final class OnboardingProvider
    extends $NotifierProvider<Onboarding, OnboardingState> {
  /// Контроллер процесса приветствия.
  ///
  /// Использует [keepAlive: true], чтобы состояние сохранялось в течение всей сессии.
  OnboardingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingHash();

  @$internal
  @override
  Onboarding create() => Onboarding();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingState>(value),
    );
  }
}

String _$onboardingHash() => r'bebf5c695dec0b0a6b73d3b98ded710bf12c35f6';

/// Контроллер процесса приветствия.
///
/// Использует [keepAlive: true], чтобы состояние сохранялось в течение всей сессии.

abstract class _$Onboarding extends $Notifier<OnboardingState> {
  OnboardingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingState, OnboardingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingState, OnboardingState>,
              OnboardingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
