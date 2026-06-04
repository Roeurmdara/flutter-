import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/habit_model.dart';

class HabitCardWidget extends StatefulWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewDetails;

  const HabitCardWidget({
    super.key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onViewDetails,
  });

  @override
  State<HabitCardWidget> createState() => _HabitCardWidgetState();
}

class _HabitCardWidgetState extends State<HabitCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnim;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: widget.isCompleted ? 1.0 : 0.0,
    );
  }

  @override
  void didUpdateWidget(covariant HabitCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _checkAnim.forward();
      } else {
        _checkAnim.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkAnim.dispose();
    super.dispose();
  }

  Color _getCategoryColor() {
    // Use habit's custom color if available, otherwise use category color
    final colorHex = widget.habit.colorHex ?? widget.habit.categoryColor;
    if (colorHex != null) {
      try {
        return Color(
            int.parse(colorHex.replaceFirst('#', ''), radix: 16) + 0xFF000000);
      } catch (e) {
        return AppColors.primaryPurple;
      }
    }
    return AppColors.primaryPurple;
  }

  String _getEmojiForCard() {
    // Use habit's custom emoji if available, otherwise use category emoji
    return widget.habit.emoji ?? widget.habit.categoryIcon ?? '✨';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();
    final habitEmoji = _getEmojiForCard();

    return GestureDetector(
      onLongPress: () => _showHabitOptions(context),
      onTap: widget.onEdit, // ← this opens detail screen
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: widget.isCompleted
              ? (isDark
                  ? AppColors.darkSurfaceElevated.withOpacity(0.6)
                  : AppColors.successSoft.withOpacity(0.3))
              : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isCompleted
                ? (isDark ? AppColors.darkBorder : AppColors.success.withOpacity(0.2))
                : (isDark ? AppColors.darkBorder : categoryColor.withOpacity(0.15)),
            width: 1,
          ),
          boxShadow: widget.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: isDark ? Colors.black12 : AppColors.shadowLight,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Left accent strip
            Container(
              width: 3,
              height: 36,
              decoration: BoxDecoration(
                color: widget.isCompleted
                    ? AppColors.success.withOpacity(0.5)
                    : categoryColor.withOpacity(0.7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),

            // Emoji badge
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    categoryColor.withOpacity(0.15),
                    categoryColor.withOpacity(0.08),
                  ],
                ),
                border: Border.all(
                  color: categoryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(habitEmoji, style: const TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(width: 14),

            // Habit name + category
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.habit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.isCompleted
                          ? (isDark ? Colors.white38 : Colors.black26)
                          : (isDark ? AppColors.darkText : AppColors.lightText),
                      decoration: widget.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: isDark ? Colors.white24 : Colors.black12,
                    ),
                  ),
                  if (widget.habit.category != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.habit.category!,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: widget.isCompleted
                            ? (isDark ? Colors.white24 : Colors.black12)
                            : categoryColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Toggle — stopPropagation so it doesn't trigger onViewDetails
            GestureDetector(
              onTap: () {
                widget.onToggle();
              },
              behavior: HitTestBehavior.opaque,
              child: ScaleTransition(
                scale: Tween<double>(begin: 1.0, end: 1.15)
                    .animate(CurvedAnimation(
                  parent: _checkAnim,
                  curve: Curves.easeOutBack,
                )),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isCompleted
                        ? AppColors.success.withOpacity(0.15)
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isCompleted
                          ? AppColors.success
                          : (isDark
                              ? AppColors.darkBorder
                              : categoryColor.withOpacity(0.3)),
                      width: 2,
                    ),
                  ),
                  child: widget.isCompleted
                      ? const Center(
                          child: Icon(
                            Icons.check_rounded,
                            color: AppColors.success,
                            size: 18,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHabitOptions(BuildContext context) {
    final categoryColor = _getCategoryColor();

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: categoryColor),
              title: const Text('Edit Habit'),
              onTap: () {
                Navigator.pop(context);
                widget.onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Habit'),
              onTap: () {
                Navigator.pop(context);
                widget.onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
