import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../../core/theme/app_colors.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? placeholder;
  final bool obscureText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;

  const AppInput({
    super.key,
    this.controller,
    this.placeholder,
    this.obscureText = false,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final border = isDark
        ? ShadBorder.all(color: AppColors.darkBorder, width: 1, radius: const BorderRadius.all(Radius.circular(12)))
        : ShadBorder.all(color: AppColors.lightBorder, width: 1, radius: const BorderRadius.all(Radius.circular(12)));

    final focusBorder = ShadBorder.all(
      color: AppColors.primaryPurple,
      width: 1.5,
      radius: const BorderRadius.all(Radius.circular(12)),
    );

    return ShadInput(
      controller: controller,
      placeholder: placeholder != null ? Text(placeholder!) : null,
      obscureText: obscureText,
      leading: prefix,
      trailing: suffix,
      keyboardType: keyboardType,
      onChanged: onChanged,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines,
      style: TextStyle(
        color: isDark ? AppColors.darkText : AppColors.lightText,
        fontSize: 14,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: ShadDecoration(
        border: border,
        focusedBorder: focusBorder,
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
    );
  }
}
