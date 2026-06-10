import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/habit_model.dart';
import '../../widgets/create_habit_modal.dart';
import '../../../data/providers/habit_provider.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final Habit habit;
  final DateTime selectedDate;

  const HabitDetailScreen({
    super.key,
    required this.habit,
    required this.selectedDate,
  });

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF6F5F3),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Habit Details',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.08,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              widget.habit.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
        toolbarHeight: 64,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      body: CreateHabitModal(
        editingHabit: widget.habit,
        onSubmit: (data) async {
          try {
            await ref.read(habitsProvider.notifier).updateHabit(
                  widget.habit.id,
                  title: data['title'] as String?,
                  description: data['description'] as String?,
                  frequencyType: data['frequencyType'] as String?,
                  frequencyConfig: (data['frequencyConfig'] as List<dynamic>?)
                      ?.map((e) => e.toString())
                      .toList(),
                  categoryId: data['categoryId'] as String?,
                  startDate: data['startDate'] as DateTime?,
                  endDate: data['endDate'] as DateTime?,
                  emoji: data['emoji'] as String?,
                  colorHex: data['color'] as String?,
                );
          } catch (e) {
            // ignore - CreateHabitModal shows feedback
          }
        },
        onDelete: () async {
          final navigator = Navigator.of(context);
          try {
            await ref
                .read(habitsProvider.notifier)
                .deleteHabit(widget.habit.id);
            navigator.pop();
          } catch (_) {}
        },
      ),
    );
  }
}
