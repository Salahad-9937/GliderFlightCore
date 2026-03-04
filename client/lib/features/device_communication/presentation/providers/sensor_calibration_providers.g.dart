// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_calibration_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SensorCalibration)
final sensorCalibrationProvider = SensorCalibrationProvider._();

final class SensorCalibrationProvider
    extends $NotifierProvider<SensorCalibration, CalibrationState> {
  SensorCalibrationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sensorCalibrationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sensorCalibrationHash();

  @$internal
  @override
  SensorCalibration create() => SensorCalibration();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CalibrationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CalibrationState>(value),
    );
  }
}

String _$sensorCalibrationHash() => r'd8ab5ded3149c4219e558d1978c2c9667ee6564b';

abstract class _$SensorCalibration extends $Notifier<CalibrationState> {
  CalibrationState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CalibrationState, CalibrationState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CalibrationState, CalibrationState>,
              CalibrationState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
