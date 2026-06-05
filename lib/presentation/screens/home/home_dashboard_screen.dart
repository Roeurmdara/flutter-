import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/habit_model.dart';
import '../../widgets/create_habit_modal.dart';
import '../../widgets/shadcn/app_button.dart';
import '../../widgets/shadcn/app_card.dart';
import '../../widgets/shadcn/app_search_bar.dart';
import '../../widgets/shadcn/job_card.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../habit/habit_detail_screen.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  final Function(bool isDark) onThemeToggle;
  final bool isDarkMode;

  const HomeDashboardScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  bool _showCalendar = false;
  bool _isSearchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitState = ref.watch(habitsProvider);
    final habitsForDate = ref.watch(habitsForDateProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);
    final currentStreak = ref.watch(currentStreakProvider);
    final selectedDate = habitState.selectedDate;
    final authState = ref.watch(authProvider);
    final userName = authState.user?.username ?? 'User';

    final visibleHabits = _filterHabits(habitsForDate);
    final pendingHabits = visibleHabits
        .where((h) => !(habitState.completedStatus[h.id] ?? false))
        .toList();
    final doneHabits = visibleHabits
        .where((h) => habitState.completedStatus[h.id] ?? false)
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: _isSearchOpen
            ? AppSearchBar(
                controller: _searchController,
                hintText: 'Search habits...',
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                onClear: _closeSearch,
              )
            : Image.asset(
                'assets/images/meeeee.png',
                height: 50,
              ),
        centerTitle: false,
        titleSpacing: 16,
        actions: [
          if (!_isSearchOpen)
            IconButton(
              tooltip: 'Search habits',
              onPressed: _openSearch,
              icon: Icon(
                Icons.search_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            )
          else
            IconButton(
              tooltip: 'Close search',
              onPressed: _closeSearch,
              icon: Icon(
                Icons.close_rounded,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(habitsProvider.notifier).loadHabits();
        },
        color: AppColors.primaryPurple,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              _buildGreetingCard(isDark, completionRate, habitsForDate.length,
                  userName, currentStreak),
              const SizedBox(height: 24),

              // Date Selector
              _buildDateSelector(isDark, selectedDate),
              const SizedBox(height: 4),

              // Calendar (toggleable)
              if (_showCalendar) ...[
                const SizedBox(height: 12),
                _buildCalendarView(isDark, selectedDate),
                const SizedBox(height: 12),
              ],

              const SizedBox(height: 16),
              _buildDashboardToolbar(isDark, habitsForDate.length),
              const SizedBox(height: 18),

              // Loading
              if (habitState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (habitsForDate.isEmpty)
                _buildEmptyState(isDark)
              else if (visibleHabits.isEmpty)
                _buildNoSearchResults(isDark)
              else ...[
                // Pending habits
                if (pendingHabits.isNotEmpty) ...[
                  _buildSectionTitle('To Do', isDark, pendingHabits.length),
                  const SizedBox(height: 10),
                  _buildHabitList(
                    isDark,
                    pendingHabits,
                    habitState,
                    selectedDate,
                    isPending: true,
                  ),
                ],

                // Done section
                if (doneHabits.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Done', isDark, doneHabits.length),
                  const SizedBox(height: 10),
                  _buildHabitList(
                    isDark,
                    doneHabits,
                    habitState,
                    selectedDate,
                    isPending: false,
                  ),
                ],
              ],

              // Error
              if (habitState.error != null) ...[
                const SizedBox(height: 16),
                Container(
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
                        child: Text(
                          'Error: ${habitState.error}',
                          style: AppTypography.bodySmall(AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  void _openSearch() {
    setState(() => _isSearchOpen = true);
  }

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _isSearchOpen = false;
      _searchQuery = '';
    });
  }

  List<Habit> _filterHabits(List<Habit> habits) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return habits;

    return habits.where((habit) {
      final title = habit.title.toLowerCase();
      final category = (habit.category ?? '').toLowerCase();
      final frequency = habit.frequency.toLowerCase();
      return title.contains(query) ||
          category.contains(query) ||
          frequency.contains(query);
    }).toList();
  }

  Widget _buildGreetingCard(bool isDark, int completionRate, int totalHabits,
    String userName, int streak) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.primaryPurple.withOpacity(0.35),
          AppColors.primaryPurpleDark.withOpacity(0.18),
        ],
      ),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Colors.white.withOpacity(0.18),
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
                'Good ${_getGreeting()}, $userName!',
                style: AppTypography.headlineMedium(Colors.white),
              ),
              const SizedBox(height: 3),
              Text(
                'Keep streaks alive today',
                style: AppTypography.bodyMedium(
                  Colors.white.withOpacity(0.82),
                ),
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  _buildGlassChip(
                      '📋 $totalHabits Habits Today', AppColors.primaryPurpleDark),
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
                        Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: completionRate / 100,
                      strokeWidth: 5,
                      strokeCap: StrokeCap.round,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryPurple.withOpacity(0.9),
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      final config = _getFlameConfig(streak);
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
                                  _getStreakGif(streak),
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
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  '🔥 $streak',
                                  style: AppTypography.labelSmall(Colors.white)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
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
              style: AppTypography.bodySmall(Colors.white.withOpacity(0.9))
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildDateSelector(bool isDark, DateTime selectedDate) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDateArrow(Icons.chevron_left_rounded, isDark, () {
            final previousDate = selectedDate.subtract(const Duration(days: 1));
            ref.read(habitsProvider.notifier).selectDate(previousDate);
          }),
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
                onPressed: () {
                  setState(() {
                    _showCalendar = !_showCalendar;
                  });
                },
                icon: Icon(
                  _showCalendar
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
          _buildDateArrow(Icons.chevron_right_rounded, isDark, () {
            final nextDate = selectedDate.add(const Duration(days: 1));
            ref.read(habitsProvider.notifier).selectDate(nextDate);
          }),
        ],
      ),
    );
  }

  Widget _buildDateArrow(IconData icon, bool isDark, VoidCallback onTap) {
    return AppButton(
      variant: AppButtonVariant.outline,
      width: 40,
      height: 40,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(12),
      onPressed: onTap,
      child: Icon(
        icon,
        size: 22,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
    );
  }

  Widget _buildDashboardToolbar(bool isDark, int totalHabits) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final searchActive = _searchQuery.trim().isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      shadows: [
        BoxShadow(
          color: isDark
              ? Colors.black.withValues(alpha: 0.18)
              : Colors.black.withValues(alpha: 0.04),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Habit pipeline',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      searchActive
                          ? '${_filterHabits(ref.watch(habitsForDateProvider)).length} matching habits'
                          : '$totalHabits scheduled for this day',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
              AppButton(
                variant: AppButtonVariant.ghost,
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                icon: const Icon(Icons.add_rounded, size: 17),
                onPressed: () => _showCreateHabitModal(),
                child: const Text('New'),
              ),
            ],
          ),
          if (searchActive) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryPurple.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    size: 14,
                    color: AppColors.primaryPurple,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Searching "${_searchQuery.trim()}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalendarView(bool isDark, DateTime selectedDate) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        focusedDay: selectedDate,
        selectedDayPredicate: (day) => isSameDay(selectedDate, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() => _showCalendar = false);
          ref.read(habitsProvider.notifier).selectDate(selectedDay);
        },
        calendarStyle: CalendarStyle(
          cellMargin: const EdgeInsets.all(4),
          selectedDecoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.heroGradient,
            ),
            shape: BoxShape.circle,
          ),
          todayDecoration: BoxDecoration(
            color: AppColors.primaryPurple.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          defaultTextStyle: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? Colors.white : Colors.black,
          ),
          weekendTextStyle: GoogleFonts.inter(
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
          selectedTextStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right_rounded,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildHabitList(
    bool isDark,
    List<Habit> habits,
    HabitState habitState,
    DateTime selectedDate, {
    required bool isPending,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted = habitState.completedStatus[habit.id] ?? false;
        final categoryColor = _getCategoryColor(habit);
        final habitEmoji = habit.emoji ?? habit.categoryIcon ?? '✨';

        return GestureDetector(
          onLongPress: () => _showHabitOptions(context, habit),
          child: JobCard(
            title: habit.title,
            subtitle: habit.category ?? '',
            leadingEmoji: habitEmoji,
            tags: [habit.frequency],
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HabitDetailScreen(
                    habit: habit,
                    selectedDate: selectedDate,
                  ),
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
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
                child: Image.asset(
                  'assets/images/hi.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                  colorBlendMode: BlendMode.modulate,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No habits for this day',
              style: GoogleFonts.poppins(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your first habit',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? Colors.white38 : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 34,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 12),
          Text(
            'No matching habits',
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Try a different title, category, or frequency.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark, [int? count]) {
    final themeColor = title == 'Done' ? AppColors.success : AppColors.primaryPurple;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: themeColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: themeColor.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: themeColor,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: themeColor,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
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

  void _showEditHabitModal(Habit habit) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateHabitModal(
        editingHabit: habit,
        onSubmit: (data) {
          ref.read(habitsProvider.notifier).updateHabit(
                habit.id,
                title: data['title'],
                description: data['description'],
                categoryId: data['categoryId'],
                frequencyType: data['frequencyType'],
                frequencyConfig: data['frequencyConfig'],
                startDate: data['startDate'],
                endDate: data['endDate'],
                emoji: data['emoji'],
                colorHex: data['color'],
              );
        },
        onDelete: () {
          Navigator.pop(context);
          _showDeleteConfirmation(habit.id, habit.title);
        },
      ),
    );
  }

  void _showCreateHabitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateHabitModal(),
    );
  }

  void _showHabitOptions(BuildContext context, Habit habit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryColor = _getCategoryColor(habit);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
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
            Text(
              habit.title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            AppButton(
              variant: AppButtonVariant.secondary,
              onPressed: () {
                Navigator.pop(context);
                _showEditHabitModal(habit);
              },
              icon: Icon(Icons.edit, color: categoryColor, size: 18),
              child: const Text('Edit Habit'),
            ),
            const SizedBox(height: 10),
            AppButton(
              variant: AppButtonVariant.destructive,
              onPressed: () {
                Navigator.pop(context);
                _showDeleteConfirmation(habit.id, habit.title);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              child: const Text('Delete Habit'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(Habit habit) {
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

  void _showDeleteConfirmation(String habitId, String habitTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "$habitTitle"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(habitsProvider.notifier).deleteHabit(habitId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  String _getStreakGif(int streak) {
    if (streak >= 20) return 'assets/images/fire-flames.gif';
    if (streak >= 10) return 'assets/images/flame02.gif';
    return 'assets/images/flame.gif';
  }

  Map<String, dynamic> _getFlameConfig(int streak) {
    if (streak >= 20) {
      return {
        'alignment': const Alignment(0.2, 0.0), // ← adjust for legendary flame
        'size': 120.0, // ← adjust size
        'angle': 0.0, // ← adjust tilt
      };
    } else if (streak >= 10) {
      return {
        'alignment': const Alignment(0.2, 0.1), // ← adjust for epic flame
        'size': 120.0,
        'angle': 0.0,
      };
    } else {
      return {
        'alignment': const Alignment(-1.3, 0.1), // ← your original flame
        'size': 100.0,
        'angle': 0.1,
      };
    }
  }
}
