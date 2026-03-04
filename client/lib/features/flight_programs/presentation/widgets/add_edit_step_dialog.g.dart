// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_edit_step_dialog.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel для управления состоянием формы.

@ProviderFor(StepEditor)
final stepEditorProvider = StepEditorFamily._();

/// ViewModel для управления состоянием формы.
final class StepEditorProvider
    extends $NotifierProvider<StepEditor, FlightProgramStep> {
  /// ViewModel для управления состоянием формы.
  StepEditorProvider._({
    required StepEditorFamily super.from,
    required FlightProgramStep? super.argument,
  }) : super(
         retry: null,
         name: r'stepEditorProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$stepEditorHash();

  @override
  String toString() {
    return r'stepEditorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  StepEditor create() => StepEditor();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FlightProgramStep value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FlightProgramStep>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StepEditorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$stepEditorHash() => r'97e4331add648cef48f7a040c8f2924741e4ec68';

/// ViewModel для управления состоянием формы.

final class StepEditorFamily extends $Family
    with
        $ClassFamilyOverride<
          StepEditor,
          FlightProgramStep,
          FlightProgramStep,
          FlightProgramStep,
          FlightProgramStep?
        > {
  StepEditorFamily._()
    : super(
        retry: null,
        name: r'stepEditorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// ViewModel для управления состоянием формы.

  StepEditorProvider call(FlightProgramStep? initial) =>
      StepEditorProvider._(argument: initial, from: this);

  @override
  String toString() => r'stepEditorProvider';
}

/// ViewModel для управления состоянием формы.

abstract class _$StepEditor extends $Notifier<FlightProgramStep> {
  late final _$args = ref.$arg as FlightProgramStep?;
  FlightProgramStep? get initial => _$args;

  FlightProgramStep build(FlightProgramStep? initial);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<FlightProgramStep, FlightProgramStep>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FlightProgramStep, FlightProgramStep>,
              FlightProgramStep,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
