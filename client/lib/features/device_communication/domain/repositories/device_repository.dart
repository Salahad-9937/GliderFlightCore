import '../../../../features/flight_programs/domain/entities/flight_program.dart';
import '../entities/device.dart';

/// Абстрактный репозиторий для взаимодействия с устройством.
abstract class DeviceRepository {
  /// Пытается подключиться к устройству в режиме точки доступа.
  Future<Device> connectToDeviceAP();

  /// Загружает полетную программу на устройство.
  Future<bool> uploadProgram(String ipAddress, FlightProgram program);
}