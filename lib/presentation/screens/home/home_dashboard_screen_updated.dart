import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/models/habit_model.dart';
import '../../widgets/habit_card_widget.dart';
import '../../widgets/create_habit_modal.dart';

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
  late DateTime _selectedDate;
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitState = ref.watch(habitsProvider);
    final habitsForDate = ref.watch(habitsForDateProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/meeeee.png',
          height: 50,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger refresh by reloading habits
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              _buildGreetingCard(isDark, completionRate, habitsForDate.length),
              const SizedBox(height: 24),

              // Date Selector with Calendar
              _buildDateSelector(isDark),
              const SizedBox(height: 24),

              if (_showCalendar) ...[
                _buildCalendarView(isDark),
                const SizedBox(height: 24),
              ],

              // Habits for Selected Date
              _buildSectionTitle(
                  'Habits for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                  isDark),
              const SizedBox(height: 12),

              if (habitState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (habitsForDate.isEmpty)
                _buildEmptyState(isDark)
              else
                _buildHabitsGrid(isDark, habitsForDate, habitState),

              const SizedBox(height: 24),

              // Stats Section
              if (habitsForDate.isNotEmpty) ...[
                _buildSectionTitle('Today\'s Statistics', isDark),
                const SizedBox(height: 12),
                _buildStatsRow(isDark, habitsForDate, habitState),
                const SizedBox(height: 24),
              ],

              // Error Handling
              if (habitState.error != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    'Error: ${habitState.error}',
                    style: AppTypography.bodySmall(AppColors.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(bool isDark, int completionRate, int totalHabits) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getGreeting()}, User!',
            style: AppTypography.headlineMedium(Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'Keep your streaks alive today',
            style: AppTypography.bodyMedium(
              Colors.white.withOpacity(0.82),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildGlassChip('🔥 7 Day Streak', AppColors.primaryPurple),
              const SizedBox(width: 10),
              _buildGlassChip(
                  '✅ $totalHabits Habits', AppColors.primaryPurpleDark),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: completionRate / 100,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.secondaryGreen,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Completion: $completionRate%',
            style: AppTypography.bodySmall(Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _selectedDate =
                      _selectedDate.subtract(const Duration(days: 1));
                  ref.read(habitsProvider.notifier).selectDate(_selectedDate);
                });
              },
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _showCalendar = !_showCalendar;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryPurple,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat('MMM dd, yyyy').format(_selectedDate),
                      style: AppTypography.labelLarge(
                        isDark ? Colors.white : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {
                setState(() {
                  _selectedDate = _selectedDate.add(const Duration(days: 1));
                  ref.read(habitsProvider.notifier).selectDate(_selectedDate);
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarView(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TableCalendar(
          firstDay: DateTime.utc(2020),
          lastDay: DateTime.utc(2030),
          focusedDay: _selectedDate,
          selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDate = selectedDay;
              _showCalendar = false;
              ref.read(habitsProvider.notifier).selectDate(_selectedDate);
            });
          },
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(4),
            selectedDecoration: const BoxDecoration(
              color: AppColors.primaryPurple,
              shape: BoxShape.circle,
            ),
            todayDecoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            defaultTextStyle: AppTypography.bodySmall(
              isDark ? Colors.white : Colors.black,
            ),
            weekendTextStyle: AppTypography.bodySmall(
              isDark ? Colors.white70 : Colors.black54,
            ),
            selectedTextStyle: AppTypography.bodySmall(Colors.white),
          ),
          headerStyle: HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
            titleTextStyle: AppTypography.labelLarge(
              isDark ? Colors.white : Colors.black,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: isDark ? Colors.white : Colors.black,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHabitsGrid(
      bool isDark, List<Habit> habits, HabitState habitState) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habits.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted = habitState.completedStatus[habit.id] ?? false;

        return HabitCardWidget(
          habit: habit,
          isCompleted: isCompleted,
          onToggle: () {
            if (isCompleted) {
              ref.read(habitsProvider.notifier).unmarkHabitAsDone(
                    habit.id,
                    _selectedDate,
                  );
            } else {
              ref.read(habitsProvider.notifier).markHabitAsDone(
                    habit.id,
                    _selectedDate,
                  );
            }
          },
          onEdit: () {
            _showEditHabitModal(habit);
          },
          onDelete: () {
            _showDeleteConfirmation(habit.id, habit.title);
          },
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: AppColors.primaryPurple.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No habits for this date',
            style: AppTypography.headlineSmall(
              isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add a new habit to get started!',
            style: AppTypography.bodySmall(
              isDark ? Colors.white54 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
      bool isDark, List<Habit> habits, HabitState habitState) {
    final completed =
        habits.where((h) => habitState.completedStatus[h.id] ?? false).length;
    final total = habits.length;
    final completion = total > 0 ? ((completed / total) * 100).toInt() : 0;

    return Row(
      children: [
        Expanded(
              child: _buildStatCard(
            isDark,
            '${habits.length}',
            'Total Habits',
            Icons.assignment,
            AppColors.primaryPurpleDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            '$completed',
            'Completed',
            Icons.check_circle,
            AppColors.secondaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            '$completion%',
            'Progress',
            Icons.trending_up,
            AppColors.primaryPurpleDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    bool isDark,
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTypography.headlineSmall(
              isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall(
              isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.headlineSmall(
        isDark ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildGlassChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: AppTypography.bodySmall(Colors.white),
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
                frequencyType: data['frequencyType'],
                frequencyConfig: data['frequencyConfig'],
              );
        },
      ),
    );
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
    if (hour < 12) {
      return 'Morning';
    } else if (hour < 17) {
      return 'Afternoon';
    } else {
      return 'Evening';
    }
  }
}
