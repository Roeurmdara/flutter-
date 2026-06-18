import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/models/habit_model.dart';
import '../../widgets/shadcn/app_button.dart';
import '../../widgets/shadcn/app_card.dart';
import '../../widgets/shadcn/job_card.dart';
import '../../widgets/create_habit_modal.dart';
import 'home_dashboard_helpers.dart';

// ── Greeting Card ─────────────────────────────────────────────────────────────

Widget buildGreetingCard(
  bool isDark,
  int completionRate,
  int totalHabits,
  String userName,
  int streak,
) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryPurple.withValues(alpha: 0.35),
          AppColors.primaryPurpleDark.withValues(alpha: 0.18),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.18),
        width: 1.2,
      ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Good ${getGreeting()}, $userName!',
                style: AppTypography.headlineMedium(Colors.white),
              ),
              const SizedBox(height: 3),
              Text(
                'Keep streaks alive today',
                style: AppTypography.bodyMedium(Colors.white.withValues(alpha: 0.82)),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildGlassChip(' $totalHabits Habits Today',
                      AppColors.primaryPurpleDark),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 110,
              width: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withValues(alpha: 0.15)),
                    ),
                  ),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: completionRate / 100,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryPurple.withValues(alpha: 0.9)),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final config = getFlameConfig(streak);
                      return Align(
                        alignment: config['alignment'] as Alignment,
                        child: Stack(
                          children: [
                            SizedBox(
                              height: config['size'] as double,
                              width: config['size'] as double,
                              child: Transform.rotate(
                                angle: config['angle'] as double,
                                child: Image.asset(
                                  getStreakGif(streak),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryPurple,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white, width: 1.5),
                                ),
                                child: Text(
                                  '🔥 $streak',
                                  style: AppTypography.labelSmall(Colors.white)
                                      .copyWith(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$completionRate%',
              style: AppTypography.bodySmall(Colors.white.withValues(alpha: 0.9))
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildGlassChip(String label, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
    ),
    child: Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Colors.white.withValues(alpha: 0.95),
      ),
    ),
  );
}

// ── Date Selector ─────────────────────────────────────────────────────────────

Widget buildDateSelector({
  required bool isDark,
  required DateTime selectedDate,
  required bool showCalendar,
  required VoidCallback onToggleCalendar,
  required VoidCallback onPrevDay,
  required VoidCallback onNextDay,
}) {
  final textColor = isDark ? AppColors.darkText : AppColors.lightText;

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppButton(
          variant: AppButtonVariant.outline,
          width: 40,
          height: 40,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(12),
          onPressed: onPrevDay,
          child: Icon(Icons.chevron_left_rounded, size: 22, color: textColor),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEEE').format(selectedDate),
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            AppButton(
              variant: AppButtonVariant.outline,
              height: 32,
              borderRadius: BorderRadius.circular(20),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              onPressed: onToggleCalendar,
              icon: Icon(
                showCalendar
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.primaryPurple,
              ),
              child: Text(
                DateFormat('MMM dd, yyyy').format(selectedDate),
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryPurple,
                ),
              ),
            ),
          ],
        ),
        AppButton(
          variant: AppButtonVariant.outline,
          width: 40,
          height: 40,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(12),
          onPressed: onNextDay,
          child: Icon(Icons.chevron_right_rounded, size: 22, color: textColor),
        ),
      ],
    ),
  );
}

// ── Calendar ──────────────────────────────────────────────────────────────────

Widget buildCalendarView({
  required bool isDark,
  required DateTime selectedDate,
  required void Function(DateTime) onDaySelected,
}) {
  return AppCard(
    padding: const EdgeInsets.all(12),
    child: TableCalendar(
      firstDay: DateTime.utc(2020),
      lastDay: DateTime.utc(2030),
      focusedDay: selectedDate,
      selectedDayPredicate: (day) => isSameDay(selectedDate, day),
      onDaySelected: (selected, focused) => onDaySelected(selected),
      calendarStyle: CalendarStyle(
        cellMargin: const EdgeInsets.all(4),
        selectedDecoration: const BoxDecoration(
          gradient: LinearGradient(colors: AppColors.heroGradient),
          shape: BoxShape.circle,
        ),
        todayDecoration: BoxDecoration(
          color: AppColors.primaryPurple.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        defaultTextStyle: GoogleFonts.inter(
            fontSize: 13, color: isDark ? Colors.white : Colors.black),
        weekendTextStyle: GoogleFonts.inter(
            fontSize: 13, color: isDark ? Colors.white70 : Colors.black54),
        selectedTextStyle: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black),
        leftChevronIcon: Icon(Icons.chevron_left_rounded,
            color: isDark ? Colors.white : Colors.black),
        rightChevronIcon: Icon(Icons.chevron_right_rounded,
            color: isDark ? Colors.white : Colors.black),
      ),
    ),
  );
}

// ── Dashboard Toolbar ─────────────────────────────────────────────────────────

// ── Habit List ────────────────────────────────────────────────────────────────

/// 👇 This is where the habit card is rendered.
/// Each card uses [JobCard] — edit that widget to change the card's look.
Widget buildHabitList({
  required BuildContext context,
  required WidgetRef ref,
  required bool isDark,
  required List<Habit> habits,
  required HabitState habitState,
  required DateTime selectedDate,
  required bool isPending,
  required void Function(Habit) onLongPress,
}) {
  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: habits.length,
    separatorBuilder: (_, __) => const SizedBox(height: 10),
    itemBuilder: (context, index) {
      final habit = habits[index];
      final isCompleted = habitState.completedStatus[habit.id] ?? false;
      final categoryColor = getCategoryColor(habit);
      final habitEmoji = habit.emoji ?? habit.categoryIcon ?? '✨';

      return GestureDetector(
        onLongPress: () => onLongPress(habit),
        // ─────────────────────────────────────────────────────────────
        // 👇 HABIT CARD — change JobCard or swap it out here
        // ─────────────────────────────────────────────────────────────
        child: JobCard(
          title: habit.title,
          subtitle: habit.category ?? '',
          leadingEmoji: habitEmoji,
          tags: [habit.frequency],
          onTap: () {
            // Show the create/edit habit form on the same page as a bottom sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => CreateHabitModal(
                editingHabit: habit,
                onSubmit: (data) {
                  ref.read(habitsProvider.notifier).updateHabit(
                        habit.id,
                        title: data['title'],
                        description: data['description'],
                        frequencyType: data['frequencyType'],
                        frequencyConfig: data['frequencyConfig'],
                      );
                },
              ),
            );
          },
          trailing: GestureDetector(
            onTap: () {
              if (isCompleted) {
                ref
                    .read(habitsProvider.notifier)
                    .unmarkHabitAsDone(habit.id, selectedDate);
              } else {
                ref
                    .read(habitsProvider.notifier)
                    .markHabitAsDone(habit.id, selectedDate);
              }
            },
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success.withValues(alpha: 0.15)
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.success
                      : (isDark
                          ? AppColors.darkBorder
                          : categoryColor.withValues(alpha: 0.3)),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Center(
                      child: Icon(Icons.check_rounded,
                          color: AppColors.success, size: 18))
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      );
    },
  );
}

// ── Section Title ─────────────────────────────────────────────────────────────

Widget buildSectionTitle(String title, bool isDark, [int? count]) {
  final themeColor =
      title == 'Done' ? AppColors.success : AppColors.primaryPurple;
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: themeColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: themeColor.withValues(alpha: 0.25), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: themeColor)),
            if (count != null) ...[
              const SizedBox(width: 6),
              Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: themeColor, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('$count',
                  style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: themeColor)),
            ],
          ],
        ),
      ),
    ],
  );
}

// ── Empty / Error States ──────────────────────────────────────────────────────

Widget buildEmptyState(bool isDark) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primaryPurple.withValues(alpha: 0.08),
                  AppColors.primaryPurple.withValues(alpha: 0.03),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Image.asset('assets/images/hi.png',
                  width: 80,
                  height: 80,
                  cacheWidth: 160,
                  cacheHeight: 160,
                  fit: BoxFit.contain,
                  colorBlendMode: BlendMode.modulate),
            ),
          ),
          const SizedBox(height: 24),
          Text('No habits for this day',
              style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : AppColors.lightText),
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Tap the + button to create your first habit',
              style: GoogleFonts.inter(
                  fontSize: 13,
                  color:
                      isDark ? Colors.white38 : AppColors.lightTextSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

Widget buildNoSearchResults(bool isDark) {
  return AppCard(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
    child: Column(
      children: [
        Icon(Icons.search_off_rounded,
            size: 34,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary),
        const SizedBox(height: 12),
        Text('No matching habits',
            style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.lightText)),
        const SizedBox(height: 6),
        Text('Try a different title, category, or frequency.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary)),
      ],
    ),
  );
}

Widget buildErrorBanner(String error) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.errorSoft,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.error_outline_rounded,
            color: AppColors.error, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text('Error: $error',
              style: AppTypography.bodySmall(AppColors.error)),
        ),
      ],
    ),
  );
}

// ── Habit Options Sheet ───────────────────────────────────────────────────────

Widget buildHabitOptionsSheet({
  required BuildContext context,
  required Habit habit,
  required bool isDark,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
}) {
  final categoryColor = getCategoryColor(habit);
  return Container(
    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(habit.title,
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText),
            textAlign: TextAlign.center),
        const SizedBox(height: 16),
        AppButton(
          variant: AppButtonVariant.secondary,
          onPressed: onEdit,
          icon: Icon(Icons.edit, color: categoryColor, size: 18),
          child: const Text('Edit Habit'),
        ),
        const SizedBox(height: 10),
        AppButton(
          variant: AppButtonVariant.destructive,
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline, size: 18),
          child: const Text('Delete Habit'),
        ),
      ],
    ),
  );
}
