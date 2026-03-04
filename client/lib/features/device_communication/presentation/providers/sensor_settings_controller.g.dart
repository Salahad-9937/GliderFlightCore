// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sensorSettingsController)
final sensorSettingsControllerProvider = SensorSettingsControllerProvider._();

final class SensorSettingsControllerProvider
    extends
        $FunctionalProvider<
          SensorSettingsController,
          SensorSettingsController,
          SensorSettingsController
        >
    with $Provider<SensorSettingsController> {
  SensorSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sensorSettingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sensorSettingsControllerHash();

  @$internal
  @override
  $ProviderElement<SensorSettingsController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SensorSettingsController create(Ref ref) {
    return sensorSettingsController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SensorSettingsController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SensorSettingsController>(value),
    );
  }
}

String _$sensorSettingsControllerHash() =>
    r'3f31e0ea4550358028725404329d674b9243dca2';
