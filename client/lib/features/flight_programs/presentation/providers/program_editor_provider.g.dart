// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_editor_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Контроллер управления состоянием текущей редактируемой программы.

@ProviderFor(ProgramEditor)
final programEditorProvider = ProgramEditorProvider._();

/// Контроллер управления состоянием текущей редактируемой программы.
final class ProgramEditorProvider
    extends $NotifierProvider<ProgramEditor, ProgramEditorState> {
  /// Контроллер управления состоянием текущей редактируемой программы.
  ProgramEditorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programEditorProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programEditorHash();

  @$internal
  @override
  ProgramEditor create() => ProgramEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramEditorState>(value),
    );
  }
}

String _$programEditorHash() => r'021753d5eb927d3382488c4660c9941a0ca7c9fe';

/// Контроллер управления состоянием текущей редактируемой программы.

abstract class _$ProgramEditor extends $Notifier<ProgramEditorState> {
  ProgramEditorState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProgramEditorState, ProgramEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProgramEditorState, ProgramEditorState>,
              ProgramEditorState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
