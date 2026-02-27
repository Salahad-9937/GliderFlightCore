import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../flight_programs/domain/entities/flight_program.dart';
import '../../domain/entities/device_status.dart';
import 'device_connection_providers.dart';
import 'device_usecase_providers.dart';

enum UploadResult { success, failure, notConnected }

/// Контроллер процесса прошивки полетной программы.
class ProgramUploadController {
  final Ref _ref;

  ProgramUploadController(this._ref);

  /// Загружает программу на устройство, приостанавливая телеметрию.
  Future<UploadResult> uploadProgram(FlightProgram program) async {
    final deviceState = _ref.read(deviceConnectionNotifierProvider);
    final connectionNotifier = _ref.read(
      deviceConnectionNotifierProvider.notifier,
    );

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

final programUploadControllerProvider = Provider<ProgramUploadController>((
  ref,
) {
  return ProgramUploadController(ref);
});
