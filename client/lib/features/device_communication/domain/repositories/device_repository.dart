import '../../../../features/flight_programs/domain/entities/flight_program.dart';
import '../entities/device.dart';

/// Абстрактный репозиторий для взаимодействия с устройством.
abstract class DeviceRepository {
  /// Пытается подключиться к устройству в режиме точки доступа.
  Future<Device> connectToDeviceAP();

  /// Загружает полетную программу на устройство.
  Future<bool> uploadProgram(String ipAddress, FlightProgram program);

  /// Обнуляет текущую высоту (Zero).
  Future<bool> zeroAltitude(String ipAddress);

  /// Запускает процесс калибровки (Calibrate).
  Future<bool> startCalibration(String ipAddress);

  /// Отменяет текущую операцию (Zero или Calibrate).
  Future<bool> cancelCalibration(String ipAddress);

  /// Сохраняет калибровку в энергонезависимую память (Save).
  Future<bool> saveCalibration(String ipAddress);
}