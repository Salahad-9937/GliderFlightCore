import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/value_objects/servo_angle.dart';

/// Визуализатор положения качалки сервопривода.
class ServoVisualizer extends StatelessWidget {
  final ServoAngle angle;
  const ServoVisualizer({super.key, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            // Используется готовое значение в радианах из домена
            angle: angle.radians,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 14),
                Container(
                  width: 14,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(1),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
