import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  HabitState({
    this.habits = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    DateTime? selectedDate,
    this.completedStatus = const {},
    this.completedDatesMap = const {},
  }) : selectedDate = selectedDate ?? DateTime.now();

  HabitState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    DateTime? selectedDate,
    Map<String, bool>? completedStatus,
    Map<String, Set<String>>? completedDatesMap,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      completedStatus: completedStatus ?? this.completedStatus,
      completedDatesMap: completedDatesMap ?? this.completedDatesMap,
    );
  }
}

// Main Habits Notifier
class HabitsNotifier extends StateNotifier<HabitState> {
  final HabitService _service;

  HabitsNotifier(this._service) : super(HabitState()) {
    loadHabits();
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
      final habits = await _service.getAllHabits();
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

  // Create new habit
  Future<void> createHabit({
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
      );

      final updatedHabits = [...state.habits, newHabit];
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
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _service.markHabitAsDone(habitId, date);

      final dateStr = _formatDate(date);

      // Update local completion tracking map
      final updatedDatesMap =
          Map<String, Set<String>>.from(state.completedDatesMap);
      final currentDates = updatedDatesMap[habitId] ?? {};
      updatedDatesMap[habitId] = {...currentDates, dateStr};

      final completedStatus = Map<String, bool>.from(state.completedStatus);
      completedStatus[habitId] = true;

      state = state.copyWith(
        completedDatesMap: updatedDatesMap,
        completedStatus: completedStatus,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  // Unmark habit as done for specific date only (does NOT affect other days)
  Future<void> unmarkHabitAsDone(String habitId, DateTime date) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _service.unmarkHabitAsDone(habitId, date);

      final dateStr = _formatDate(date);

      // Update local completion tracking map
      final updatedDatesMap =
          Map<String, Set<String>>.from(state.completedDatesMap);
      final currentDates = updatedDatesMap[habitId] ?? {};
      updatedDatesMap[habitId] =
          currentDates.where((d) => d != dateStr).toSet();

      final completedStatus = Map<String, bool>.from(state.completedStatus);
      completedStatus[habitId] = false;

      state = state.copyWith(
        completedDatesMap: updatedDatesMap,
        completedStatus: completedStatus,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
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
