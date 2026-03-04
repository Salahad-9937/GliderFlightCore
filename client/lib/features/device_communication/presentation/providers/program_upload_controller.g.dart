// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_upload_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programUploadController)
final programUploadControllerProvider = ProgramUploadControllerProvider._();

final class ProgramUploadControllerProvider
    extends
        $FunctionalProvider<
          ProgramUploadController,
          ProgramUploadController,
          ProgramUploadController
        >
    with $Provider<ProgramUploadController> {
  ProgramUploadControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programUploadControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programUploadControllerHash();

  @$internal
  @override
  $ProviderElement<ProgramUploadController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramUploadController create(Ref ref) {
    return programUploadController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramUploadController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramUploadController>(value),
    );
  }
}

String _$programUploadControllerHash() =>
    r'2339fd936568737e8a56c6a17e7a1fe567fa600f';
