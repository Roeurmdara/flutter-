import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/habit_model.dart';
import '../../widgets/habit_card_widget.dart';
import '../../widgets/create_habit_modal.dart';
import '../habit/habit_detail_screen.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  final Function(bool isDark) onThemeToggle;
  final bool isDarkMode;

  const HomeDashboardScreen({
    Key? key,
    required this.onThemeToggle,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  bool _showCalendar = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final habitState = ref.watch(habitsProvider);
    final habitsForDate = ref.watch(habitsForDateProvider);
    final completionRate = ref.watch(todayCompletionRateProvider);
    final selectedDate = habitState.selectedDate;
    final authState = ref.watch(authProvider);
    final userName = authState.user?.username ?? 'User';

    final pendingHabits = habitsForDate
        .where((h) => !(habitState.completedStatus[h.id] ?? false))
        .toList();
    final doneHabits = habitsForDate
        .where((h) => habitState.completedStatus[h.id] ?? false)
        .toList();

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
          await ref.read(habitsProvider.notifier).loadHabits();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              _buildGreetingCard(
                  isDark, completionRate, habitsForDate.length, userName),
              const SizedBox(height: 20),

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

              // Loading
              if (habitState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (habitsForDate.isEmpty)
                _buildEmptyState(isDark)
              else ...[
                // Pending habits (no section header, just listed)
                if (pendingHabits.isNotEmpty)
                  _buildHabitList(
                    isDark,
                    pendingHabits,
                    habitState,
                    selectedDate,
                    isPending: true,
                  ),

                // Done section
                if (doneHabits.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildSectionTitle('Done', isDark),
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
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    'Error: ${habitState.error}',
                    style: AppTypography.bodySmall(AppColors.error),
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

  Widget _buildGreetingCard(
      bool isDark, int completionRate, int totalHabits, String userName) {
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
            'Good ${_getGreeting()}, ${userName}!',
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
              valueColor: AlwaysStoppedAnimation<Color>(
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

  Widget _buildDateSelector(bool isDark, DateTime selectedDate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            final previousDate = selectedDate.subtract(const Duration(days: 1));
            ref.read(habitsProvider.notifier).selectDate(previousDate);
          },
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _showCalendar = !_showCalendar;
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .center, // Centers the day and the badge relative to each other
            mainAxisSize: MainAxisSize.min,
            children: [
              // Big, prominent Day text positioned right in the middle above the badge
              Text(
                DateFormat('EEEE').format(selectedDate), // Outputs: "Monday"
                style: AppTypography.headlineMedium(
                  // Switched to a larger headline style
                  isDark ? Colors.white : AppColors.lightText,
                ).copyWith(
                  fontWeight: FontWeight
                      .w800, // Extra bold to look much bigger and dominant
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                  height:
                      2), // Generous spacing to separate the dominant text from the badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryPurple,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize
                      .min, // Keeps the badge snug around the date text
                  children: [
                    const SizedBox(width: 5),
                    Text(
                      DateFormat('MMM dd, yyyy').format(selectedDate),
                      style: AppTypography.labelLarge(
                        isDark
                            ? Colors.white70
                            : AppColors.lightText.withOpacity(
                                0.8), // Slightly dimmed to keep focus on the day above
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            final nextDate = selectedDate.add(const Duration(days: 1));
            ref.read(habitsProvider.notifier).selectDate(nextDate);
          },
        ),
      ],
    );
  }

  Widget _buildCalendarView(bool isDark, DateTime selectedDate) {
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
          focusedDay: selectedDate,
          selectedDayPredicate: (day) => isSameDay(selectedDate, day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() => _showCalendar = false);
            ref.read(habitsProvider.notifier).selectDate(selectedDay);
          },
          calendarStyle: CalendarStyle(
            cellMargin: const EdgeInsets.all(4),
            selectedDecoration: BoxDecoration(
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
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final habit = habits[index];
        final isCompleted = habitState.completedStatus[habit.id] ?? false;

        return HabitCardWidget(
          habit: habit,
          isCompleted: isCompleted,
          onToggle: () {
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
          onEdit: () => _showEditHabitModal(habit),
          onDelete: () => _showDeleteConfirmation(habit.id, habit.title),
          onViewDetails: () {
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
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Hugs content cleanly
          children: [
            // Minimalist illustration centered
            Image.asset(
              'assets/images/hi.png',
              width: 160,
              height: 160,
              fit: BoxFit.contain,
              // Dynamically tints the image to match the dark/light aesthetic softly

              colorBlendMode: BlendMode.modulate,
            ),
            const SizedBox(height: 28), // Generous spacing for breathing room
            Text(
              'Hi! No habits for this date',
              style: AppTypography.headlineSmall(
                isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Click Add +',
              style: AppTypography.bodySmall(
                isDark ? Colors.white38 : Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppTypography.headlineSmall(
        isDark ? Colors.white54 : Colors.black38,
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
}
