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
    if (habit.categoryColor != null) {
      try {
        // Parse hex color string
        return Color(
            int.parse(habit.categoryColor!.replaceFirst('#', ''), radix: 16) +
                0xFF000000);
      } catch (e) {
        return AppColors.primaryPurple;
      }
    }
    return AppColors.primaryPurple;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor();
    final categoryEmoji = habit.categoryIcon ?? '✨';

    return GestureDetector(
      onLongPress: () => _showHabitOptions(context),
      onTap: onViewDetails,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            // Emoji Badge with Color Background
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: categoryColor.withOpacity(0.15),
                border: Border.all(
                  color: categoryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  categoryEmoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Text content
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onEdit,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
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
                        if (habit.currentStreak > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: categoryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '🔥 ${habit.currentStreak}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: categoryColor,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _FrequencyBadge(
                            frequency: habit.frequency, color: categoryColor),
                        const SizedBox(width: 8),
                        if (habit.category != null)
                          Text(
                            '${habit.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.bodySmall(
                              isDark ? Colors.white30 : Colors.black38,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Circle toggle — tap to complete, tap again to undo
            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.secondaryGreen.withOpacity(0.2)
                      : Colors.transparent,
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.secondaryGreen
                        : categoryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Center(
                        child: Icon(
                          Icons.check_rounded,
                          color: AppColors.secondaryGreen,
                          size: 20,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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

  String _getFrequencyLabel(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return frequency;
    }
  }
}

/// Frequency Badge with Emoji
class _FrequencyBadge extends StatelessWidget {
  final String frequency;
  final Color color;

  const _FrequencyBadge({
    required this.frequency,
    required this.color,
  });

  String _getFrequencyEmoji(String freq) {
    switch (freq.toLowerCase()) {
      case 'daily':
        return '📅';
      case 'weekly':
        return '📆';
      case 'monthly':
        return '📊';
      default:
        return '⏰';
    }
  }

  String _getFrequencyLabel(String freq) {
    switch (freq.toLowerCase()) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Weekly';
      case 'monthly':
        return 'Monthly';
      default:
        return freq;
    }
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _getFrequencyEmoji(frequency);
    final label = _getFrequencyLabel(frequency);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
