import '../entities/device.dart';

/// Абстрактный репозиторий для взаимодействия с устройством.
abstract class DeviceRepository {
  /// Пытается подключиться к устройству в режиме точки доступа.
  Future<Device> connectToDeviceAP();

  // TODO: Добавить методы для отправки WiFi-кредов, отладки и т.д.
}