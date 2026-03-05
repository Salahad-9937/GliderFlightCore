import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/string_extensions.dart';

/// Унифицированное поле ввода в тактическом стиле.
///
/// Инкапсулирует стили границ, шрифтов и валидации (Stage 5.4).
class TacticalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool autofocus;

  const TacticalTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofocus,
      style: AppTextStyles.telemetryValueMedium.copyWith(fontSize: 18),
      decoration: InputDecoration(
        labelText: label.t,
        labelStyle: AppTextStyles.instrumentLabel,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorStyle: AppTextStyles.instrumentLabel.copyWith(
          color: AppColors.error,
          fontSize: 9,
        ),
      ),
      validator: validator,
    );
  }
}
