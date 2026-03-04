// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_connection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Нотификатор управления сессией связи с устройством.

@ProviderFor(DeviceConnection)
final deviceConnectionProvider = DeviceConnectionProvider._();

/// Нотификатор управления сессией связи с устройством.
final class DeviceConnectionProvider
    extends $NotifierProvider<DeviceConnection, Device> {
  /// Нотификатор управления сессией связи с устройством.
  DeviceConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceConnectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceConnectionHash();

  @$internal
  @override
  DeviceConnection create() => DeviceConnection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Device value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Device>(value),
    );
  }
}

String _$deviceConnectionHash() => r'e0b2dc795e3be38ed63c9ae32422a88d330d5de4';

/// Нотификатор управления сессией связи с устройством.

abstract class _$DeviceConnection extends $Notifier<Device> {
  Device build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Device, Device>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Device, Device>,
              Device,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
