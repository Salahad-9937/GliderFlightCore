// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flight_program_usecase_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Провайдер сценария получения программ.

@ProviderFor(getProgramsUseCase)
final getProgramsUseCaseProvider = GetProgramsUseCaseProvider._();

/// Провайдер сценария получения программ.

final class GetProgramsUseCaseProvider
    extends
        $FunctionalProvider<
          GetProgramsUseCase,
          GetProgramsUseCase,
          GetProgramsUseCase
        >
    with $Provider<GetProgramsUseCase> {
  /// Провайдер сценария получения программ.
  GetProgramsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getProgramsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getProgramsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetProgramsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetProgramsUseCase create(Ref ref) {
    return getProgramsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetProgramsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetProgramsUseCase>(value),
    );
  }
}

String _$getProgramsUseCaseHash() =>
    r'a4cce829a2eebfa03d6c35c6e40561627b850220';

/// Провайдер сценария сохранения программ.

@ProviderFor(saveProgramUseCase)
final saveProgramUseCaseProvider = SaveProgramUseCaseProvider._();

/// Провайдер сценария сохранения программ.

final class SaveProgramUseCaseProvider
    extends
        $FunctionalProvider<
          SaveProgramUseCase,
          SaveProgramUseCase,
          SaveProgramUseCase
        >
    with $Provider<SaveProgramUseCase> {
  /// Провайдер сценария сохранения программ.
  SaveProgramUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveProgramUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveProgramUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveProgramUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveProgramUseCase create(Ref ref) {
    return saveProgramUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveProgramUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveProgramUseCase>(value),
    );
  }
}

String _$saveProgramUseCaseHash() =>
    r'7f7b5ea2af357d5311749ea42d093e861d4ca48c';

/// Провайдер сценария удаления программ.

@ProviderFor(deleteProgramUseCase)
final deleteProgramUseCaseProvider = DeleteProgramUseCaseProvider._();

/// Провайдер сценария удаления программ.

final class DeleteProgramUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteProgramUseCase,
          DeleteProgramUseCase,
          DeleteProgramUseCase
        >
    with $Provider<DeleteProgramUseCase> {
  /// Провайдер сценария удаления программ.
  DeleteProgramUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteProgramUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteProgramUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteProgramUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteProgramUseCase create(Ref ref) {
    return deleteProgramUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteProgramUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteProgramUseCase>(value),
    );
  }
}

String _$deleteProgramUseCaseHash() =>
    r'184e7a792c360f48aa34ab5cced0c688d0847aec';
