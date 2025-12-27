import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../features/flight_programs/domain/entities/flight_program.dart';
import '../../domain/entities/device.dart';
import '../../domain/entities/device_status.dart';
import '../../domain/repositories/device_repository.dart';

/// Провайдер для репозитория устройства.
final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepositoryImpl();
});

/// Реализация репозитория для взаимодействия с устройством по HTTP.
class DeviceRepositoryImpl implements DeviceRepository {
  // IP-адрес ESP8266 по умолчанию в режиме точки доступа.
  static const String _apIpAddress = '192.168.4.1';

  @override
  Future<Device> connectToDeviceAP() async {
    try {
      final url = Uri.http(_apIpAddress, '/status');
      // Таймаут короткий, чтобы интерфейс не зависал при опросе
      final response = await http.get(url).timeout(const Duration(milliseconds: 1500));

      if (response.statusCode == 200) {
        // Парсим JSON ответ от платы
        final Map<String, dynamic> json = jsonDecode(response.body);
        
        return Device(
          status: DeviceStatus.connected,
          ipAddress: _apIpAddress,
          // Маппинг полей из JSON (см. StatusHandler.h)
          isHardwareOk: json['hw_ok'] ?? false,
          isCalibrating: json['calibrating'] ?? false,
          isCalibrated: json['calibrated'] ?? false,
          isMonitoring: json['monitoring'] ?? false,
          isLogging: json['logging'] ?? false,
          storedBasePressure: (json['stored_base'] as num?)?.toDouble(),
          currentPressure: (json['current_p'] as num?)?.toDouble(),
          altitude: (json['alt'] as num?)?.toDouble(),
          temperature: (json['temp'] as num?)?.toDouble(),
          isStable: json['stable'] ?? false,
          basePressure: (json['base'] as num?)?.toDouble(),
        );
      } else {
        return Device(
          status: DeviceStatus.error,
          errorMessage: 'Ошибка устройства: ${response.statusCode}',
        );
      }
    } catch (e) {
      return Device(
        status: DeviceStatus.error,
        errorMessage: 'Нет связи с $_apIpAddress',
      );
    }
  }

  @override
  Future<bool> uploadProgram(String ipAddress, FlightProgram program) async {
    try {
      final url = Uri.http(ipAddress, '/program');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: program.toJson(),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}