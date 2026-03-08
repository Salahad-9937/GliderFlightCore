// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_connection_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Нотификатор управления сессией связи.
/// Использует autoDispose для автоматического управления ресурсами.

@ProviderFor(DeviceConnection)
final deviceConnectionProvider = DeviceConnectionProvider._();

/// Нотификатор управления сессией связи.
/// Использует autoDispose для автоматического управления ресурсами.
final class DeviceConnectionProvider
    extends $NotifierProvider<DeviceConnection, Device> {
  /// Нотификатор управления сессией связи.
  /// Использует autoDispose для автоматического управления ресурсами.
  DeviceConnectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceConnectionProvider',
        isAutoDispose: true,
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

String _$deviceConnectionHash() => r'90fc57c7cdbb861dc6986e12b4a139876e514f4c';

/// Нотификатор управления сессией связи.
/// Использует autoDispose для автоматического управления ресурсами.

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
