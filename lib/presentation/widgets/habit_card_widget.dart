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

  const HabitCardWidget({
    Key? key,
    required this.habit,
    required this.isCompleted,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onLongPress: () => _showHabitOptions(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted
                ? AppColors.secondaryGreen
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
            width: isCompleted ? 2 : 1,
          ),
          boxShadow: isCompleted
              ? [
                  BoxShadow(
                    color: AppColors.secondaryGreen.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isCompleted
                          ? AppColors.secondaryGreen
                          : (isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder),
                      border: Border.all(
                        color: isCompleted
                            ? AppColors.secondaryGreen
                            : AppColors.primaryPurple,
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 18,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: AppTypography.labelLarge(
                          isCompleted
                              ? (isDark ? Colors.white70 : Colors.black54)
                              : (isDark ? Colors.white : Colors.black),
                        ).copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.repeat,
                            size: 14,
                            color: AppColors.primaryPurple,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getFrequencyLabel(habit.frequency),
                            style: AppTypography.bodySmall(
                              isDark ? Colors.white54 : Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Badge
                if (isCompleted)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.secondaryGreen,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: AppTypography.bodySmall(AppColors.secondaryGreen),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Category and Streak
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(habit.category ?? '')
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getCategoryColor(habit.category ?? ''),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    habit.category ?? '',
                    style: AppTypography.bodySmall(
                      _getCategoryColor(habit.category ?? ''),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.currentStreak} day streak',
                      style: AppTypography.bodySmall(
                        isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Completion Rate
            if (habit.currentStreak > 0) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: habit.completionRate / 100,
                  minHeight: 6,
                  backgroundColor: (isDark ? Colors.white24 : Colors.black12),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryPurple,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Completion: ${habit.completionRate}%',
                style: AppTypography.bodySmall(
                  isDark ? Colors.white54 : Colors.black38,
                ),
              ),
            ],

            // Completed Section - shown when habit is completed
            if (isCompleted) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondaryGreen.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.secondaryGreen,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Completed Today! 🎉',
                          style: AppTypography.labelLarge(
                            AppColors.secondaryGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Completed at ${_getCompletionTime()}',
                      style: AppTypography.bodySmall(
                        isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                    if (habit.currentStreak > 0) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 16,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${habit.currentStreak} day streak!',
                              style: AppTypography.bodySmall(Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onToggle,
                      child: Text(
                        'Undo',
                        style: AppTypography.bodySmall(
                          AppColors.primaryPurple,
                        ).copyWith(
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showHabitOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'health':
        return AppColors.secondaryGreen;
      case 'productivity':
        return AppColors.primaryPurple;
      case 'fitness':
        return Colors.orange;
      case 'learning':
        return Colors.blue;
      case 'personal':
        return Colors.pink;
      default:
        return AppColors.primaryPurple;
    }
  }

  String _getCompletionTime() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final paddedMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$paddedMinute $ampm';
  }
}
