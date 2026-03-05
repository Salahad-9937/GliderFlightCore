import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/string_extensions.dart';

/// Контейнер в стиле бортового прибора.
class InstrumentCard extends StatelessWidget {
  final String? label;
  final Widget child;
  final List<Widget>? actions;
  final Color? borderColor;

  const InstrumentCard({
    super.key,
    this.label,
    required this.child,
    this.actions,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: borderColor ?? AppColors.border, width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) _CardHeader(label: label!, actions: actions),
          Padding(padding: const EdgeInsets.all(12.0), child: child),
        ],
      ),
    );
  }
}

/// Приватный компонент заголовка карточки (ISP).
class _CardHeader extends StatelessWidget {
  final String label;
  final List<Widget>? actions;

  const _CardHeader({required this.label, this.actions});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.t, style: AppTextStyles.instrumentLabel),
          if (actions != null) Row(children: actions!),
        ],
      ),
    );
  }
}
