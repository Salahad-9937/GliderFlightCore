import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
      // Отправляем запрос с коротким таймаутом.
      final response = await http.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        // Успешный пинг, устройство подключено.
        return const Device(status: DeviceStatus.connected, ipAddress: _apIpAddress);
      } else {
        // Устройство ответило, но не так, как ожидалось.
        return Device(
          status: DeviceStatus.error,
          errorMessage: 'Неверный ответ от устройства (код: ${response.statusCode})',
        );
      }
    } catch (e) {
      // Таймаут или другая сетевая ошибка.
      return Device(
        status: DeviceStatus.error,
        errorMessage: 'Устройство не найдено по адресу $_apIpAddress. Убедитесь, что вы подключены к его Wi-Fi сети.',
      );
    }
  }
}