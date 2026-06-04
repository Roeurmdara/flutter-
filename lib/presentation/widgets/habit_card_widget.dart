import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/habit_model.dart';

class HabitCardWidget extends StatelessWidget {
  final Habit habit;
  final bool isCompleted;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewDetails;

  const HabitCardWidget({
    Key? key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
    this.onViewDetails,
  }) : super(key: key);

  Color _getCategoryColor() {
    // Use habit's custom color if available, otherwise use category color
    final colorHex = habit.colorHex ?? habit.categoryColor;
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
    return habit.emoji ?? habit.categoryIcon ?? '✨';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();
    final habitEmoji = _getEmojiForCard();

    return GestureDetector(
      onLongPress: () => _showHabitOptions(context),
      onTap: onEdit, // ← this opens detail screen
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCompleted
                ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                : categoryColor.withOpacity(0.3),
            width: isCompleted ? 1 : 1.5,
          ),
        ),
        child: Row(
          children: [
            // Emoji badge
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: categoryColor.withOpacity(0.15),
                border: Border.all(
                  color: categoryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(habitEmoji, style: const TextStyle(fontSize: 18)),
              ),
            ),

            const SizedBox(width: 12),

            // Habit name — no GestureDetector wrapper
            Expanded(
              child: Text(
                habit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.labelLarge(
                  isCompleted
                      ? (isDark ? Colors.white38 : Colors.black26)
                      : (isDark ? Colors.white : Colors.black87),
                ).copyWith(
                  decoration: isCompleted
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Toggle — stopPropagation so it doesn't trigger onViewDetails
            GestureDetector(
              onTap: () {
                onToggle();
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.primaryPurple.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.primaryPurple.withOpacity(0.9)
                        : categoryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.primaryPurple,
                          size: 18,
                        ),
                      )
                    : const SizedBox.shrink(),
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
                onEdit();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Habit'),
              onTap: () {
                Navigator.pop(context);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
