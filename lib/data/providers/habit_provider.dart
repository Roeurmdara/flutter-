import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/habit_service.dart';
import '../models/habit_model.dart';
import 'auth_provider.dart';

final habitServiceProvider = Provider((ref) {
  final dio = Dio();

  // Watch auth state to get the token
  final authState = ref.watch(authProvider);
  final token = authState.user?.token ?? '';

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        var authToken = token;
        if (authToken.isEmpty) {
          final prefs = await SharedPreferences.getInstance();
          authToken = prefs.getString('auth_token') ??
              prefs.getString('user_token') ??
              '';
        }
        if (authToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $authToken';
        }
        return handler.next(options);
      },
    ),
  );

  return HabitService(dio);
});

// State for habits by date
class HabitState {
  final List<Habit> habits;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final DateTime selectedDate;
  final Map<String, bool>
      completedStatus; // habitId -> isCompleted for selected date
  final Map<String, Set<String>>
      completedDatesMap; // habitId -> Set of completed dates (local tracking)
  final int
      currentUserStreak; // User's current streak (days with all habits completed)

  HabitState({
    this.habits = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    DateTime? selectedDate,
    this.completedStatus = const {},
    this.completedDatesMap = const {},
    this.currentUserStreak = 0,
  }) : selectedDate = selectedDate ?? DateTime.now();

  HabitState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    DateTime? selectedDate,
    Map<String, bool>? completedStatus,
    Map<String, Set<String>>? completedDatesMap,
    int? currentUserStreak,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      completedStatus: completedStatus ?? this.completedStatus,
      completedDatesMap: completedDatesMap ?? this.completedDatesMap,
      currentUserStreak: currentUserStreak ?? this.currentUserStreak,
    );
  }
}

// Main Habits Notifier
class HabitsNotifier extends StateNotifier<HabitState> {
  final HabitService _service;

  static const _kCompletedDatesKey = 'habits_completed_dates_map_v1';
  static const _kSelectedDateKey = 'habits_selected_date_v1';
  static const _kCurrentStreakKey = 'habits_current_streak_v1';

  HabitsNotifier(this._service) : super(HabitState()) {
    _init();
  }

  Future<void> _init() async {
    await _loadLocalCompletedDates();
    await _loadLocalStreak();
    await loadHabits();
    // Ensure the app shows today's date on startup so per-day completions are visible
    try {
      selectDate(DateTime.now());
    } catch (_) {}
  }

  // Load locally persisted completed dates map from SharedPreferences
  Future<void> _loadLocalCompletedDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_kCompletedDatesKey);
      // Restore selected date if previously saved
      final selectedDateStr = prefs.getString(_kSelectedDateKey);
      if (selectedDateStr != null && selectedDateStr.isNotEmpty) {
        try {
          final parsed = DateTime.parse(selectedDateStr);
          state = state.copyWith(selectedDate: _dateOnly(parsed));
        } catch (_) {}
      }
      if (jsonStr == null || jsonStr.isEmpty) return;
      final Map<String, dynamic> decoded = Map<String, dynamic>.from(
          jsonDecode(jsonStr) as Map<String, dynamic>);
      final Map<String, Set<String>> map = {};
      decoded.forEach((key, value) {
        if (value is List) {
          map[key] = value.map((e) => e.toString()).toSet();
        }
      });
      state = state.copyWith(completedDatesMap: map);
      // Recompute completedStatus for the currently selected date
      _updateCompletionStatus(state.habits);
    } catch (_) {
      // ignore errors reading local cache
    }
  }

  Future<void> _saveLocalCompletedDates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final serialized =
          state.completedDatesMap.map((k, v) => MapEntry(k, v.toList()));
      final jsonStr = jsonEncode(serialized);
      await prefs.setString(_kCompletedDatesKey, jsonStr);
    } catch (_) {
      // ignore write errors
    }
  }

  // Load locally persisted streak from SharedPreferences
  Future<void> _loadLocalStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final streak = prefs.getInt(_kCurrentStreakKey) ?? 0;
      state = state.copyWith(currentUserStreak: streak);
    } catch (_) {
      // ignore errors reading local cache
    }
  }

  // Save locally persisted streak to SharedPreferences
  Future<void> _saveLocalStreak() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kCurrentStreakKey, state.currentUserStreak);
    } catch (_) {
      // ignore write errors
    }
  }

  /// Calculate the current user streak based on completed habits
  /// Streak counts consecutive days where ALL habits for that day were completed
  /// Works backwards from today
  void _updateStreak() {
    if (state.habits.isEmpty) {
      state = state.copyWith(currentUserStreak: 0);
      return;
    }

    int currentStreak = 0;
    // Start counting from today so completing today's habits updates the streak immediately
    DateTime checkDate = _dateOnly(DateTime.now());

    // Work backwards from today to count consecutive days with all habits completed
    while (true) {
      final dateStr = _formatDate(checkDate);

      // Get habits that should be completed on this date
      final habitsForDate = state.habits.where((habit) {
        if (!_isWithinDateRange(habit, checkDate)) return false;
        switch (habit.frequency.toLowerCase()) {
          case 'daily':
            return true;
          case 'weekly':
            return checkDate.weekday == habit.startDate.weekday;
          case 'monthly':
            return checkDate.day == habit.startDate.day;
          default:
            return true;
        }
      }).toList();

      // If no habits for this date, end streak
      if (habitsForDate.isEmpty) break;

      // Check if all habits are completed for this date
      final allCompleted = habitsForDate.every((habit) {
        final completedDates = state.completedDatesMap[habit.id] ?? {};
        return completedDates.contains(dateStr);
      });

      if (allCompleted) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        // Break in the streak, stop counting
        break;
      }
    }

    if (currentStreak != state.currentUserStreak) {
      state = state.copyWith(currentUserStreak: currentStreak);
      _saveLocalStreak();
    }
  }

  // FIX 1: _formatDate added as an instance method so it's accessible
  // throughout the class (was previously only a top-level function)
  String _formatDate(DateTime date) {
    final d = _dateOnly(date);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadHabits() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
    } catch (_) {
      // Notifier already disposed, ignore
      return;
    }

    try {
      final fetchedHabits = await _service.getAllHabits();
      // Merge any server-reported `today_status` into the local completed dates map
      // so server-driven completions are respected across restarts.
      final dateStr = _formatDate(DateTime.now());
      final mergedMap = Map<String, Set<String>>.from(state.completedDatesMap);
      for (final habit in fetchedHabits) {
        if (habit.todayStatus.toLowerCase() == 'completed') {
          final current = mergedMap[habit.id] ?? <String>{};
          mergedMap[habit.id] = {...current, dateStr};
        }
      }

      // Apply merged map, persist, then update completion status based on selected date
      state = state.copyWith(completedDatesMap: mergedMap);
      await _saveLocalCompletedDates();
      final habits = _applyLocalCompletionState(fetchedHabits);
      _updateCompletionStatus(habits);

      try {
        state = state.copyWith(habits: habits, isLoading: false);
      } catch (_) {
        // Disposed during async operation, ignore
      }
    } catch (e) {
      try {
        // Don't show 401 as a persistent error — it just means not authed yet
        state = state.copyWith(
          isLoading: false,
          error: e is DioException && e.response?.statusCode == 401
              ? null // silence auth errors on initial load
              : e.toString(),
        );
      } catch (_) {
        // Disposed during error handling, ignore
      }
    }
  }

  void _updateCompletionStatus(List<Habit> habits) {
    // Update based on the selected date using local tracking map
    final dateStr = _formatDate(state.selectedDate);
    final completedStatus = <String, bool>{};

    for (final habit in habits) {
      // Check if the selected date is in the local completed dates map
      final completedDates = state.completedDatesMap[habit.id] ?? {};
      completedStatus[habit.id] = completedDates.contains(dateStr);
    }

    state = state.copyWith(completedStatus: completedStatus);
  }

  List<Habit> _applyLocalCompletionState(List<Habit> habits) {
    // Use the currently selected date (restored on startup) when applying
    // local completion state so UI matches the calendar selection.
    final selectedStr = _formatDate(state.selectedDate);

    return habits.map((habit) {
      final completedDates = state.completedDatesMap[habit.id] ?? {};
      final isCompletedForSelectedDate = completedDates.contains(selectedStr);
      final nextTodayStatus =
          isCompletedForSelectedDate ? 'completed' : habit.todayStatus;

      return habit.todayStatus == nextTodayStatus
          ? habit
          : habit.copyWith(todayStatus: nextTodayStatus);
    }).toList();
  }

  List<Habit> _updateHabitTodayStatus(
    String habitId,
    DateTime date,
    String todayStatus,
  ) {
    // Consider the "today" relative to the currently selected date
    final isToday = _formatDate(date) == _formatDate(state.selectedDate);
    if (!isToday) return state.habits;

    return state.habits.map((habit) {
      return habit.id == habitId
          ? habit.copyWith(todayStatus: todayStatus)
          : habit;
    }).toList();
  }

  List<Habit> _replaceHabit(Habit updatedHabit) {
    return state.habits.map((habit) {
      return habit.id == updatedHabit.id ? updatedHabit : habit;
    }).toList();
  }

  // Create new habit
  Future<Habit> createHabit({
    required String categoryId,
    required String title,
    required String description,
    required String frequencyType,
    required List<String> frequencyConfig,
    required String goalType,
    required int targetValue,
    required String targetUnit,
    required DateTime startDate,
    DateTime? endDate,
    required String visibility,
    String? emoji,
    String? colorHex,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final newHabit = await _service.createHabit(
        categoryId: categoryId,
        title: title,
        description: description,
        frequencyType: frequencyType,
        frequencyConfig: frequencyConfig,
        goalType: goalType,
        targetValue: targetValue,
        targetUnit: targetUnit,
        startDate: startDate,
        endDate: endDate,
        visibility: visibility,
        emoji: emoji,
        colorHex: colorHex,
      );

      final updatedHabits = [...state.habits, newHabit];
      _updateCompletionStatus(updatedHabits);
      state = state.copyWith(
        habits: updatedHabits,
        isUpdating: false,
      );
      return newHabit;
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  // Update habit
  Future<void> updateHabit(
    String habitId, {
    String? title,
    String? description,
    String? frequencyType,
    List<String>? frequencyConfig,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? emoji,
    String? colorHex,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedHabit = await _service.updateHabit(
        habitId,
        title: title,
        description: description,
        frequencyType: frequencyType,
        frequencyConfig: frequencyConfig,
        categoryId: categoryId,
        startDate: startDate,
        endDate: endDate,
        status: status,
        emoji: emoji,
        colorHex: colorHex,
      );

      final updatedHabits = state.habits.map((habit) {
        return habit.id == habitId ? updatedHabit : habit;
      }).toList();

      _updateCompletionStatus(updatedHabits);
      state = state.copyWith(
        habits: updatedHabits,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  // Mark habit as done for specific date only (does NOT affect other days)
  Future<void> markHabitAsDone(String habitId, DateTime date) async {
    // Optimistic local update: persist immediately so UI and restarts reflect change
    state = state.copyWith(isUpdating: true, error: null);
    final dateStr = _formatDate(date);

    // Update local completion tracking map
    final updatedDatesMap =
        Map<String, Set<String>>.from(state.completedDatesMap);
    final currentDates = updatedDatesMap[habitId] ?? {};
    updatedDatesMap[habitId] = {...currentDates, dateStr};

    final completedStatus = Map<String, bool>.from(state.completedStatus);
    completedStatus[habitId] = true;

    // Apply local state and persist before calling remote API
    state = state.copyWith(
      habits: _updateHabitTodayStatus(habitId, date, 'completed'),
      completedDatesMap: updatedDatesMap,
      completedStatus: completedStatus,
      isUpdating: false,
    );
    await _saveLocalCompletedDates();
    _updateStreak(); // Update streak after marking habit as done

    try {
      final updatedHabit = await _service.markHabitAsDone(habitId, date);
      if (updatedHabit != null) {
        state = state.copyWith(habits: _replaceHabit(updatedHabit));
      }
    } catch (e) {
      // Preserve local change but record error for UI
      state = state.copyWith(error: e.toString());
    }
  }

  // Unmark habit as done for specific date only (does NOT affect other days)
  Future<void> unmarkHabitAsDone(String habitId, DateTime date) async {
    // Optimistic local unmark: update and persist immediately
    state = state.copyWith(isUpdating: true, error: null);
    final dateStr = _formatDate(date);

    final updatedDatesMap =
        Map<String, Set<String>>.from(state.completedDatesMap);
    final currentDates = updatedDatesMap[habitId] ?? {};
    updatedDatesMap[habitId] = currentDates.where((d) => d != dateStr).toSet();

    final completedStatus = Map<String, bool>.from(state.completedStatus);
    completedStatus[habitId] = false;

    state = state.copyWith(
      habits: _updateHabitTodayStatus(habitId, date, 'pending'),
      completedDatesMap: updatedDatesMap,
      completedStatus: completedStatus,
      isUpdating: false,
    );
    await _saveLocalCompletedDates();
    _updateStreak(); // Update streak after unmarking habit

    try {
      final updatedHabit = await _service.unmarkHabitAsDone(habitId, date);
      if (updatedHabit != null) {
        state = state.copyWith(habits: _replaceHabit(updatedHabit));
      }
    } catch (e) {
      // Preserve local change but notify via error
      state = state.copyWith(error: e.toString());
    }
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _service.deleteHabit(habitId);

      final updatedHabits =
          state.habits.where((habit) => habit.id != habitId).toList();
      _updateCompletionStatus(updatedHabits);

      state = state.copyWith(
        habits: updatedHabits,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  // Select date and update completion status
  void selectDate(DateTime date) {
    final selectedDate = _dateOnly(date);
    final dateStr = _formatDate(selectedDate);
    final completedStatus = <String, bool>{};

    for (final habit in state.habits) {
      // Check if this specific date is in the local completed dates map
      final completedDates = state.completedDatesMap[habit.id] ?? {};
      completedStatus[habit.id] = completedDates.contains(dateStr);
    }

    state = state.copyWith(
      selectedDate: selectedDate,
      completedStatus: completedStatus,
    );
    // persist selected date
    try {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_kSelectedDateKey, selectedDate.toIso8601String());
      });
    } catch (_) {}
  }

  // Get habits for selected date
  List<Habit> getHabitsForDate(DateTime date) {
    return state.habits.where((habit) {
      if (!_isWithinDateRange(habit, date)) return false;

      // Check frequency
      switch (habit.frequency.toLowerCase()) {
        case 'daily':
          return true;
        case 'weekly':
          return date.weekday == habit.startDate.weekday;
        case 'monthly':
          return date.day == habit.startDate.day;
        default:
          return true;
      }
    }).toList();
  }
}

// Provider
final habitsProvider = StateNotifierProvider<HabitsNotifier, HabitState>((ref) {
  final service = ref.watch(habitServiceProvider);
  return HabitsNotifier(service);
});

// Computed: Get habits for selected date
final habitsForDateProvider = Provider<List<Habit>>((ref) {
  final habitState = ref.watch(habitsProvider);
  return habitState.habits.where((habit) {
    final selectedDate = habitState.selectedDate;
    if (!_isWithinDateRange(habit, selectedDate)) return false;

    switch (habit.frequency.toLowerCase()) {
      case 'daily':
        return true;
      case 'weekly':
        return selectedDate.weekday == habit.startDate.weekday;
      case 'monthly':
        return selectedDate.day == habit.startDate.day;
      default:
        return true;
    }
  }).toList();
});

DateTime _dateOnly(DateTime date) {
  final localDate = date.toLocal();
  return DateTime(localDate.year, localDate.month, localDate.day);
}

bool _isWithinDateRange(Habit habit, DateTime date) {
  final selectedDate = _dateOnly(date);
  final startDate = _dateOnly(habit.startDate);
  final endDate = habit.endDate != null ? _dateOnly(habit.endDate!) : null;

  if (selectedDate.isBefore(startDate)) return false;
  if (endDate != null && selectedDate.isAfter(endDate)) return false;
  return true;
}

// Computed: Get completion rate for today
final todayCompletionRateProvider = Provider<int>((ref) {
  final habitState = ref.watch(habitsProvider);
  final habitsForToday = ref.watch(habitsForDateProvider);

  if (habitsForToday.isEmpty) return 0;

  final completedCount = habitsForToday
      .where((habit) => habitState.completedStatus[habit.id] ?? false)
      .length;

  return ((completedCount / habitsForToday.length) * 100).toInt();
});

// Computed: Get current user streak
final currentStreakProvider = Provider<int>((ref) {
  final habitState = ref.watch(habitsProvider);
  return habitState.currentUserStreak;
});
