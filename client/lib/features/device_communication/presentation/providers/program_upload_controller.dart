import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../flight_programs/domain/entities/flight_program.dart';
import '../../domain/entities/device_status.dart';
import 'device_connection_providers.dart';
import 'device_usecase_providers.dart';

part 'program_upload_controller.g.dart';

enum UploadResult { success, failure, notConnected }

/// Контроллер процесса прошивки полетной программы.
class ProgramUploadController {
  final Ref _ref;

  ProgramUploadController(this._ref);

  /// Загружает программу на устройство, приостанавливая телеметрию.
  Future<UploadResult> uploadProgram(FlightProgram program) async {
    // Обновлены ссылки на провайдер
    final deviceState = _ref.read(deviceConnectionProvider);
    final connectionNotifier = _ref.read(deviceConnectionProvider.notifier);

    if (deviceState.status != DeviceStatus.connected) {
      return UploadResult.notConnected;
    }

    connectionNotifier.pausePolling();

    final result = await _ref.read(uploadProgramUseCaseProvider).call(program);

    return result.fold(
      (_) {
        connectionNotifier.resumePolling();
        return UploadResult.success;
      },
      (failure) {
        connectionNotifier.resumePolling();
        return UploadResult.failure;
      },
    );
  }
}

@riverpod
ProgramUploadController programUploadController(Ref ref) {
  return ProgramUploadController(ref);
}
