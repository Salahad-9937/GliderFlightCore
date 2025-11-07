import 'device_status.dart';

/// Сущность, представляющая бортовое устройство.
class Device {
  /// Текущий статус подключения.
  final DeviceStatus status;

  /// IP-адрес устройства, если оно подключено.
  final String? ipAddress;

  /// Сообщение об ошибке, если статус error.
  final String? errorMessage;

  const Device({
    this.status = DeviceStatus.disconnected,
    this.ipAddress,
    this.errorMessage,
  });

  /// Создает копию объекта с измененными полями.
  Device copyWith({
    DeviceStatus? status,
    String? ipAddress,
    String? errorMessage,
  }) {
    return Device(
      status: status ?? this.status,
      ipAddress: ipAddress ?? this.ipAddress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}