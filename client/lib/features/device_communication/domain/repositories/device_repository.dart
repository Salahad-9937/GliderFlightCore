import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../flight_programs/domain/entities/flight_program.dart';
import '../entities/device.dart';
import '../entities/system_health.dart';

/// Абстрактный репозиторий для взаимодействия с бортовым устройством.
///
/// Все методы возвращают [Result] для явной обработки ошибок.
abstract interface class IDeviceRepository {
  /// Получает текущий статус и телеметрию устройства.
  Future<Result<Device, Failure>> getDeviceStatus();

  /// Получает расширенную диагностику системы (uptime, heap, FS).
  Future<Result<SystemHealth, Failure>> getSystemHealth();

  /// Загружает полетную программу в память устройства.
  Future<Result<void, Failure>> uploadProgram(FlightProgram program);

  /// Обнуляет текущую высоту (установка текущего давления как 0м).
  Future<Result<void, Failure>> zeroAltitude();

  /// Запускает полную процедуру калибровки датчика.
  Future<Result<void, Failure>> startCalibration();

  /// Прерывает текущую операцию (обнуление или калибровку).
  Future<Result<void, Failure>> cancelOperation();

  /// Сохраняет текущую калибровку в энергонезависимую память устройства.
  Future<Result<void, Failure>> saveCalibration();

  /// Включает или выключает активный мониторинг датчиков.
  Future<Result<void, Failure>> setSensorMonitoring(bool enable);
}
