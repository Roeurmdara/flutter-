import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/app_colors.dart';

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  destructive,
  ghost,
  link
}

class AppButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final String? text;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool loading;
  final bool enabled;
  final AppButtonVariant variant;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    this.onPressed,
    this.child,
    this.text,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.enabled = true,
    this.variant = AppButtonVariant.primary,
    this.width,
    this.height = 44,
    this.padding,
    this.borderRadius,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final buttonChild = widget.child ?? Text(widget.text ?? '');

    // Map variant to ShadButton constructor
    Widget buildButton() {
      final onPressedHandler = widget.enabled && !widget.loading ? widget.onPressed : null;
      final radius = widget.borderRadius ?? BorderRadius.circular(10);
      final padding = widget.padding ?? const EdgeInsets.symmetric(horizontal: 16);

      final dec = ShadDecoration(border: ShadBorder(radius: radius));

      switch (widget.variant) {
        case AppButtonVariant.secondary:
          return ShadButton.secondary(
            onPressed: onPressedHandler,
            leading: widget.icon,
            trailing: widget.trailingIcon,
            width: widget.width,
            height: widget.height,
            padding: padding,
            decoration: dec,
            child: buttonChild,
          );
        case AppButtonVariant.outline:
          return ShadButton.outline(
            onPressed: onPressedHandler,
            leading: widget.icon,
            trailing: widget.trailingIcon,
            width: widget.width,
            height: widget.height,
            padding: padding,
            decoration: dec,
            child: buttonChild,
          );
        case AppButtonVariant.destructive:
          return ShadButton.destructive(
            onPressed: onPressedHandler,
            leading: widget.icon,
            trailing: widget.trailingIcon,
            width: widget.width,
            height: widget.height,
            padding: padding,
            decoration: dec,
            child: buttonChild,
          );
        case AppButtonVariant.ghost:
          return ShadButton.ghost(
            onPressed: onPressedHandler,
            leading: widget.icon,
            trailing: widget.trailingIcon,
            width: widget.width,
            height: widget.height,
            padding: padding,
            decoration: dec,
            child: buttonChild,
          );
        case AppButtonVariant.link:
          return ShadButton.link(
            onPressed: onPressedHandler,
            leading: widget.icon,
            trailing: widget.trailingIcon,
            width: widget.width,
            height: widget.height,
            padding: padding,
            decoration: dec,
            child: buttonChild,
          );
        case AppButtonVariant.primary:
          return ShadButton(
            onPressed: onPressedHandler,
            leading: widget.icon,
            trailing: widget.trailingIcon,
            width: widget.width,
            height: widget.height,
            padding: padding,
            decoration: dec,
            backgroundColor: AppColors.primaryPurple,
            hoverBackgroundColor: AppColors.primaryPurpleDark,
            child: buttonChild,
          );
      }
    }

    if (widget.loading) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? Colors.white70 : AppColors.primaryPurple,
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => widget.enabled ? setState(() => _scale = 0.96) : null,
      onTapUp: (_) => widget.enabled ? setState(() => _scale = 1.0) : null,
      onTapCancel: () => widget.enabled ? setState(() => _scale = 1.0) : null,
      child: Transform.scale(
        scale: _scale,
        child: buildButton(),
      ),
    );
  }
}
