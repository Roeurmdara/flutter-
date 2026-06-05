import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final ShadBorder? border;
  final BorderRadius? borderRadius;
  final List<BoxShadow>? shadows;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final defaultBorder = isDark
        ? ShadBorder.all(color: AppColors.darkBorder, width: 1)
        : ShadBorder.all(color: AppColors.lightBorder, width: 1);

    final defaultBg = isDark
        ? AppColors.darkSurface
        : Colors.white;

    final defaultRadius = borderRadius ?? BorderRadius.circular(16);

    final defaultShadows = shadows ?? [
      BoxShadow(
        color: isDark ? Colors.black26 : AppColors.shadowLight,
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    return ShadCard(
      padding: padding ?? const EdgeInsets.all(16),
      backgroundColor: backgroundColor ?? defaultBg,
      border: border ?? defaultBorder,
      radius: defaultRadius,
      shadows: defaultShadows,
      child: child,
    );
  }
}
