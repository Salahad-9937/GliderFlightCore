import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/flight_program_step.dart';
import '../../domain/value_objects/servo_angle.dart';
import '../../domain/value_objects/step_duration.dart';

part 'step_editor_provider.g.dart';

/// Компоненты шага для типобезопасного обновления состояния.
enum DurationComponent { min, sec, ms, angle }

/// ViewModel для управления состоянием формы редактирования шага.
///
/// Инкапсулирует всю математику расчета миллисекунд и валидацию углов.
@riverpod
final class StepEditor extends _$StepEditor {
  @override
  FlightProgramStep build(FlightProgramStep? initial) {
    return initial ??
        const FlightProgramStep(
          angle: ServoAngle(90),
          duration: StepDuration(0),
        );
  }

  /// Проверяет, что длительность шага не равна нулю.
  /// Логическая проверка для предотвращения ошибок прошивки.
  bool get isDurationValid => state.duration.totalMs > 0;

  /// Обновление угла сервопривода.
  void updateAngle(int val) {
    state = state.copyWith(angle: ServoAngle(val));
  }

  /// Расчет новой длительности на основе вращения энкодера.
  void updateFromKnob(DurationComponent component, double knobValue) {
    int newTotalMs = state.duration.totalMs;
    switch (component) {
      case DurationComponent.min:
        newTotalMs += (knobValue - state.duration.minutes).toInt() * 60000;
        break;
      case DurationComponent.sec:
        newTotalMs += (knobValue - state.duration.secondsOnly).toInt() * 1000;
        break;
      case DurationComponent.ms:
        newTotalMs += (knobValue - state.duration.millisOnly).toInt();
        break;
      case DurationComponent.angle:
        updateAngle(knobValue.toInt());
        return;
    }
    state = state.copyWith(duration: StepDuration(newTotalMs));
  }

  /// Обновление компонентов длительности из текстовых полей ввода.
  void updateFromText(DurationComponent component, int val) {
    if (component == DurationComponent.angle) {
      updateAngle(val);
    } else {
      int m = state.duration.minutes;
      int s = state.duration.secondsOnly;
      int ms = state.duration.millisOnly;

      switch (component) {
        case DurationComponent.min:
          m = val;
          break;
        case DurationComponent.sec:
          s = val;
          break;
        case DurationComponent.ms:
          ms = val;
          break;
        default:
          break;
      }

      state = state.copyWith(
        duration: StepDuration.fromComponents(min: m, sec: s, ms: ms),
      );
    }
  }
}
