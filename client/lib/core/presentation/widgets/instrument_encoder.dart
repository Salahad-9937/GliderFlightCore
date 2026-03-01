import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Тактический круговой энкодер.
class InstrumentEncoder extends StatefulWidget {
  final double value;
  final double min;
  final double max;
  final double step;
  final String label;
  final String unit;
  final bool isInfinite;

  /// Значение, соответствующее полному обороту (360 градусов).
  final double fullTurnValue;
  final ValueChanged<double> onChanged;

  const InstrumentEncoder({
    super.key,
    required this.value,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    required this.label,
    required this.unit,
    this.isInfinite = false,
    this.fullTurnValue = 100,
    required this.onChanged,
  });

  @override
  State<InstrumentEncoder> createState() => _InstrumentEncoderState();
}

class _InstrumentEncoderState extends State<InstrumentEncoder> {
  double _lastRotationAngle = 0;

  // Внутренний аккумулятор для предотвращения потери микро-движений
  double _internalValue = 0;

  @override
  void initState() {
    super.initState();
    _internalValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant InstrumentEncoder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Синхронизируем внутренний счетчик при внешнем изменении (переполнение или ручной ввод)
    if (oldWidget.value != widget.value) {
      _internalValue = widget.value;
    }
  }

  void _handlePanStart(DragStartDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final touchPosition = details.localPosition - center;
    _lastRotationAngle =
        (math.atan2(touchPosition.dy, touchPosition.dx) +
            math.pi / 2 +
            2 * math.pi) %
        (2 * math.pi);
  }

  void _handlePanUpdate(DragUpdateDetails details, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final touchPosition = details.localPosition - center;
    final angle = math.atan2(touchPosition.dy, touchPosition.dx) + math.pi / 2;
    final normalizedAngle = (angle + 2 * math.pi) % (2 * math.pi);

    if (widget.isInfinite) {
      // Логика бесконечного вращения через дельту
      double delta = normalizedAngle - _lastRotationAngle;

      // Обработка перехода через верхнюю мертвую точку
      if (delta > math.pi) delta -= 2 * math.pi;
      if (delta < -math.pi) delta += 2 * math.pi;

      _internalValue += (delta / (2 * math.pi)) * widget.fullTurnValue;

      // Виртуальная "пружина": не даем аккумулятору убежать при жестком упоре в лимиты времени (0 или макс)
      final limit = widget.fullTurnValue / 4;
      if (_internalValue < widget.value - limit) {
        _internalValue = widget.value - limit;
      }
      if (_internalValue > widget.value + limit) {
        _internalValue = widget.value + limit;
      }

      double snappedValue =
          (_internalValue / widget.step).roundToDouble() * widget.step;

      if (snappedValue != widget.value) {
        HapticFeedback.selectionClick();
        widget.onChanged(snappedValue);
      }
    } else {
      // Логика ограниченного диапазона (абсолютная позиция пальца)
      double newValue =
          (normalizedAngle / (2 * math.pi)) * (widget.max - widget.min) +
          widget.min;
      newValue = newValue.clamp(widget.min, widget.max);

      double snappedValue =
          (newValue / widget.step).roundToDouble() * widget.step;

      if (snappedValue != widget.value) {
        HapticFeedback.selectionClick();
        widget.onChanged(snappedValue);
      }
    }
    _lastRotationAngle = normalizedAngle;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label.toUpperCase(), style: AppTextStyles.instrumentLabel),
        const SizedBox(height: 12),
        GestureDetector(
          onPanStart: (d) => _handlePanStart(d, const Size(100, 100)),
          onPanUpdate: (d) => _handlePanUpdate(d, const Size(100, 100)),
          child: SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: _EncoderPainter(
                value: widget.value,
                min: widget.min,
                max: widget.max,
                unit: widget.unit,
                isInfinite: widget.isInfinite,
                fullTurnValue: widget.fullTurnValue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EncoderPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final String unit;
  final bool isInfinite;
  final double fullTurnValue;

  _EncoderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.isInfinite,
    required this.fullTurnValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 4.0;

    // 1. Фоновое кольцо
    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius - strokeWidth, bgPaint);

    // 2. Активная дуга
    final activePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    double sweepAngle;
    double displayVal = value;

    if (isInfinite) {
      // Корректный остаток от деления для плавного перехода через 0
      displayVal = (value % fullTurnValue + fullTurnValue) % fullTurnValue;
      sweepAngle = (displayVal / fullTurnValue) * 2 * math.pi;
    } else {
      sweepAngle = ((value - min) / (max - min)) * 2 * math.pi;
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );

    // 3. Насечки (Ticks) - зависят от fullTurnValue, а не от isInfinite
    final tickPaint = Paint()..strokeWidth = 1.5;

    int tickCount = 12;
    if (fullTurnValue == 60) tickCount = 60; // Секунды и Минуты
    if (fullTurnValue == 1000) tickCount = 50; // Миллисекунды (20мс шаг)

    for (int i = 0; i < tickCount; i++) {
      final tickAngle = (i * (360 / tickCount)) * math.pi / 180 - math.pi / 2;

      bool isMajor = false;
      if (tickCount == 60 || tickCount == 50) {
        isMajor = (i % 5 == 0);
      } else {
        isMajor = (i % 3 == 0);
      }

      tickPaint.color = isMajor ? AppColors.primary : AppColors.borderBright;
      final double tickLength = isMajor ? 10 : 5;

      final start = Offset(
        center.dx + (radius - tickLength - 2) * math.cos(tickAngle),
        center.dy + (radius - tickLength - 2) * math.sin(tickAngle),
      );
      final end = Offset(
        center.dx + (radius - 2) * math.cos(tickAngle),
        center.dy + (radius - 2) * math.sin(tickAngle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // 4. Значение в центре
    final displayString = isInfinite
        ? displayVal.toInt().toString()
        : value.toStringAsFixed(0);

    final textPainter = TextPainter(
      text: TextSpan(
        text: displayString,
        style: AppTextStyles.telemetryValueMedium.copyWith(
          fontSize: 24,
          color: AppColors.primary,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2 + 4),
    );

    final unitPainter = TextPainter(
      text: TextSpan(
        text: unit.toUpperCase(),
        style: AppTextStyles.instrumentLabel.copyWith(fontSize: 8),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    unitPainter.paint(canvas, center - Offset(unitPainter.width / 2, -12));
  }

  @override
  bool shouldRepaint(_EncoderPainter oldDelegate) => oldDelegate.value != value;
}
