import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
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
      onRequest: (options, handler) {
        if (token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
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

  HabitState({
    this.habits = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    DateTime? selectedDate,
    this.completedStatus = const {},
  }) : selectedDate = selectedDate ?? DateTime.now();

  HabitState copyWith({
    List<Habit>? habits,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    DateTime? selectedDate,
    Map<String, bool>? completedStatus,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      completedStatus: completedStatus ?? this.completedStatus,
    );
  }
}

// Main Habits Notifier
class HabitsNotifier extends StateNotifier<HabitState> {
  final HabitService _service;

  HabitsNotifier(this._service) : super(HabitState()) {
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.getHabits();
      _updateCompletionStatus(response.data);
      state = state.copyWith(habits: response.data, isLoading: false);
    } catch (e) {
      // Don't show 401 as a persistent error — it just means not authed yet
      state = state.copyWith(
        isLoading: false,
        error: e is DioException && e.response?.statusCode == 401
            ? null // silence auth errors on initial load
            : e.toString(),
      );
    }
  }

  void _updateCompletionStatus(List<Habit> habits) {
    final completedStatus = <String, bool>{};
    for (final habit in habits) {
      // Use todayStatus from API instead of completedDates
      completedStatus[habit.id] = habit.todayStatus == 'completed';
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

  // Mark habit as done
  Future<void> markHabitAsDone(String habitId, DateTime date) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _service.markHabitAsDone(habitId, date);

      final updatedHabits = state.habits.map((habit) {
        if (habit.id == habitId) {
          return habit.copyWith(
            todayStatus: 'completed',
          );
        }
        return habit;
      }).toList() as List<Habit>;

      final completedStatus = Map<String, bool>.from(state.completedStatus);
      completedStatus[habitId] = true;

      state = state.copyWith(
        habits: updatedHabits,
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

  // Unmark habit as done
  Future<void> unmarkHabitAsDone(String habitId, DateTime date) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _service.unmarkHabitAsDone(habitId, date);

      final updatedHabits = state.habits.map((habit) {
        if (habit.id == habitId) {
          return habit.copyWith(
            todayStatus: 'pending',
          );
        }
        return habit;
      }).toList() as List<Habit>;

      final completedStatus = Map<String, bool>.from(state.completedStatus);
      completedStatus[habitId] = false;

      state = state.copyWith(
        habits: updatedHabits,
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
    state = state.copyWith(selectedDate: date); // update date first
    _updateCompletionStatus(state.habits); // then recalculate
  }

  // Get habits for selected date
  List<Habit> getHabitsForDate(DateTime date) {
    return state.habits.where((habit) {
      if (habit.startDate.isAfter(date)) return false;
      if (habit.endDate != null && habit.endDate!.isBefore(date)) return false;

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
    if (habit.startDate.isAfter(selectedDate)) return false;
    if (habit.endDate != null && habit.endDate!.isBefore(selectedDate)) {
      return false;
    }

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
