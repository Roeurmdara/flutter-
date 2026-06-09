import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/models/habit_model.dart';
import '../../widgets/create_habit_modal.dart';

import '../../widgets/shadcn/app_search_bar.dart';
import 'home_dashboard_widgets.dart';
import 'home_dashboard_helpers.dart';

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

    final visibleHabits = filterHabits(habitsForDate, _searchQuery);
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
            : Image.asset('assets/images/meeeee.png', height: 50),
        centerTitle: false,
        titleSpacing: 16,
      
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
              buildGreetingCard(isDark, completionRate, habitsForDate.length,
                  userName, currentStreak),
              const SizedBox(height: 24),
              buildDateSelector(
                isDark: isDark,
                selectedDate: selectedDate,
                showCalendar: _showCalendar,
                onToggleCalendar: () =>
                    setState(() => _showCalendar = !_showCalendar),
                onPrevDay: () => ref
                    .read(habitsProvider.notifier)
                    .selectDate(selectedDate.subtract(const Duration(days: 1))),
                onNextDay: () => ref
                    .read(habitsProvider.notifier)
                    .selectDate(selectedDate.add(const Duration(days: 1))),
              ),
              const SizedBox(height: 4),
              if (_showCalendar) ...[
                const SizedBox(height: 12),
                buildCalendarView(
                  isDark: isDark,
                  selectedDate: selectedDate,
                  onDaySelected: (day) {
                    setState(() => _showCalendar = false);
                    ref.read(habitsProvider.notifier).selectDate(day);
                  },
                ),
                const SizedBox(height: 12),
              ],
        
          
              const SizedBox(height: 18),
              if (habitState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (habitsForDate.isEmpty)
                buildEmptyState(isDark)
              else if (visibleHabits.isEmpty)
                buildNoSearchResults(isDark)
              else ...[
                if (pendingHabits.isNotEmpty) ...[
                  buildSectionTitle('To Do', isDark, pendingHabits.length),
                  const SizedBox(height: 10),
                  buildHabitList(
                    context: context,
                    ref: ref,
                    isDark: isDark,
                    habits: pendingHabits,
                    habitState: habitState,
                    selectedDate: selectedDate,
                    isPending: true,
                    onLongPress: (habit) => _showHabitOptions(context, habit),
                  ),
                ],
                if (doneHabits.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  buildSectionTitle('Done', isDark, doneHabits.length),
                  const SizedBox(height: 10),
                  buildHabitList(
                    context: context,
                    ref: ref,
                    isDark: isDark,
                    habits: doneHabits,
                    habitState: habitState,
                    selectedDate: selectedDate,
                    isPending: false,
                    onLongPress: (habit) => _showHabitOptions(context, habit),
                  ),
                ],
              ],
              if (habitState.error != null) ...[
                const SizedBox(height: 16),
                buildErrorBanner(habitState.error!),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Search ──────────────────────────────────────────────────────────────────

  void _openSearch() => setState(() => _isSearchOpen = true);

  void _closeSearch() {
    _searchController.clear();
    setState(() {
      _isSearchOpen = false;
      _searchQuery = '';
    });
  }

  // ── Modals ───────────────────────────────────────────────────────────────────

  void _showCreateHabitModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateHabitModal(),
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

  void _showHabitOptions(BuildContext context, Habit habit) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => buildHabitOptionsSheet(
        context: context,
        habit: habit,
        isDark: isDark,
        onEdit: () {
          Navigator.pop(context);
          _showEditHabitModal(habit);
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
}