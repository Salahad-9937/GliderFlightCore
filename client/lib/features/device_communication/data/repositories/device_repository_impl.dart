import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/architecture/failure.dart';
import '../../../../core/architecture/result.dart';
import '../../../../core/di/core_providers.dart';
import '../../../../core/network/i_network_client.dart';
import '../../../flight_programs/domain/entities/flight_program.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/system_health.dart';
import '../../domain/repositories/device_repository.dart';
import '../mappers/device_mapper.dart';
import '../models/device_status_dto.dart';
import '../models/system_health_dto.dart';

/// Провайдер реализации репозитория устройства.
final deviceRepositoryProvider = Provider<IDeviceRepository>((ref) {
  final networkClient = ref.watch(networkClientProvider);
  return DeviceRepositoryImpl(networkClient);
});

/// Реализация репозитория для взаимодействия с ESP8266 по HTTP.
class DeviceRepositoryImpl implements IDeviceRepository {
  final INetworkClient _network;

  DeviceRepositoryImpl(this._network);

  @override
  Future<Result<Device, Failure>> getDeviceStatus() async {
    final result = await _network.get('/status');

    return result.fold(
      (json) => Success(
        DeviceMapper.toEntity(
          DeviceStatusDto.fromJson(json),
          ipAddress: '192.168.4.1', // Базовый IP для AP режима
        ),
      ),
      (failure) => Error(failure),
    );
  }

  @override
  Future<Result<SystemHealth, Failure>> getSystemHealth() async {
    final result = await _network.get('/system');

    return result.fold(
      (json) => Success(
        DeviceMapper.toSystemHealthEntity(SystemHealthDto.fromJson(json)),
      ),
      (failure) => Error(failure),
    );
  }

  @override
  Future<Result<void, Failure>> uploadProgram(FlightProgram program) async {
    // Используем toMap() сущности (пока маппер для программ не создан)
    final result = await _network.post('/program', body: program.toMap());

    return result.fold((_) => const Success(null), (failure) => Error(failure));
  }

  @override
  Future<Result<void, Failure>> zeroAltitude() async {
    final result = await _network.get('/zero');
    return result.fold((_) => const Success(null), (f) => Error(f));
  }

  @override
  Future<Result<void, Failure>> startCalibration() async {
    final result = await _network.get('/calibrate');
    return result.fold((_) => const Success(null), (f) => Error(f));
  }

  @override
  Future<Result<void, Failure>> cancelOperation() async {
    final result = await _network.get('/cancel');
    return result.fold((_) => const Success(null), (f) => Error(f));
  }

  @override
  Future<Result<void, Failure>> saveCalibration() async {
    final result = await _network.get('/calibrate/save');
    return result.fold((_) => const Success(null), (f) => Error(f));
  }

  @override
  Future<Result<void, Failure>> setSensorMonitoring(bool enable) async {
    final result = await _network.get(
      '/baro',
      queryParameters: {'enable': enable ? '1' : '0'},
    );
    return result.fold((_) => const Success(null), (f) => Error(f));
  }
}
