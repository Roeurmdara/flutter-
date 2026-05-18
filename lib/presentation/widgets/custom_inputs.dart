import 'package:flutter/material.dart';
import 'package:habit_tracker/core/theme/app_colors.dart';
import 'package:habit_tracker/core/theme/app_typography.dart';

// Custom Text Field
class CustomTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconPressed;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;

  const CustomTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconPressed,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: AppTypography.labelLarge(
            isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          validator: widget.validator,
          onChanged: widget.onChanged,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          readOnly: widget.readOnly,
          focusNode: _focusNode,
          style: AppTypography.bodyMedium(
            isDark ? AppColors.darkText : AppColors.lightText,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.bodyMedium(
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _focusNode.hasFocus
                        ? AppColors.primaryPurple
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? IconButton(
                    icon: Icon(widget.suffixIcon),
                    color: _focusNode.hasFocus
                        ? AppColors.primaryPurple
                        : (isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary),
                    onPressed: widget.onSuffixIconPressed ??
                        (widget.obscureText
                            ? () {
                                setState(() {
                                  _obscureText = !_obscureText;
                                });
                              }
                            : null),
                  )
                : null,
            filled: true,
            fillColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primaryPurple,
                width: 2,
              ),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// Habit Progress Card
class HabitProgressCard extends StatelessWidget {
  final String title;
  final String icon;
  final int progress; // 0-100
  final int streak;
  final bool isCompletedToday;
  final VoidCallback onTap;
  final VoidCallback onPress;

  const HabitProgressCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.progress,
    required this.streak,
    required this.isCompletedToday,
    required this.onTap,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title,
                        style: AppTypography.titleMedium(
                          isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Streak badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '🔥 $streak',
                    style: AppTypography.labelSmall(AppColors.accentOrange),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: AppTypography.bodySmall(
                        isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '$progress%',
                      style: AppTypography.labelSmall(
                        isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 6,
                    backgroundColor: isDark
                        ? AppColors.darkBackground
                        : AppColors.lightBackground,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompletedToday
                          ? AppColors.success
                          : AppColors.primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Check button
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: onPress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompletedToday
                      ? AppColors.success
                      : AppColors.primaryPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isCompletedToday ? '✓ Done Today' : 'Mark Complete',
                  style: AppTypography.buttonSmall(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Empty State Widget
class EmptyState extends StatelessWidget {
  final String icon;
  final String title;
  final String description;
  final String? buttonLabel;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonLabel,
    this.onButtonPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTypography.headlineMedium(
              isDark ? AppColors.darkText : AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTypography.bodyMedium(
              isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonLabel != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonLabel!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
