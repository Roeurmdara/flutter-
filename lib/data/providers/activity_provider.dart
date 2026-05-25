import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/activity_model.dart';
import '../services/habit_service.dart';
import 'habit_provider.dart';

// Activity State
class ActivityState {
  final List<Activity> activities;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final String? selectedHabitId;
  final DateTime? selectedDate;

  ActivityState({
    this.activities = const [],
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.selectedHabitId,
    this.selectedDate,
  });

  ActivityState copyWith({
    List<Activity>? activities,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    String? selectedHabitId,
    DateTime? selectedDate,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: error,
      selectedHabitId: selectedHabitId ?? this.selectedHabitId,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

// Activities Notifier
class ActivitiesNotifier extends StateNotifier<ActivityState> {
  final HabitService _service;

  ActivitiesNotifier(this._service) : super(ActivityState());

  // Load activities for a specific habit and date
  Future<void> loadActivities(String habitId, DateTime date) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedHabitId: habitId,
      selectedDate: date,
    );
    try {
      final activities = await _service.getAllActivities(
        habitId: habitId,
        date: date,
      );
      state = state.copyWith(activities: activities, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Create new activity
  Future<void> createActivity({
    required String habitId,
    required String activityType,
    required String value,
    required String unit,
    required DateTime settlementPeriodDate,
    String? note,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final newActivity = await _service.createActivity(
        habitId: habitId,
        activityType: activityType,
        value: value,
        unit: unit,
        settlementPeriodDate: settlementPeriodDate,
        note: note,
      );

      state = state.copyWith(
        activities: [...state.activities, newActivity],
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  // Mark activity as complete
  Future<void> markActivityComplete(
    String habitId,
    String activityId,
  ) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedActivity =
          await _service.markActivityAsComplete(habitId, activityId);

      final updatedActivities = state.activities.map((activity) {
        return activity.id == activityId
            ? activity.copyWith(isCompleted: true)
            : activity;
      }).toList();

      state = state.copyWith(
        activities: updatedActivities,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  // Unmark activity as complete
  Future<void> unmarkActivityComplete(
    String habitId,
    String activityId,
  ) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedActivity =
          await _service.unmarkActivityAsComplete(habitId, activityId);

      final updatedActivities = state.activities.map((activity) {
        return activity.id == activityId
            ? activity.copyWith(isCompleted: false)
            : activity;
      }).toList();

      state = state.copyWith(
        activities: updatedActivities,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  // Delete activity
  Future<void> deleteActivity(String habitId, String activityId) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      await _service.deleteActivity(habitId, activityId);

      final updatedActivities = state.activities
          .where((activity) => activity.id != activityId)
          .toList();

      state = state.copyWith(
        activities: updatedActivities,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  // Update activity
  Future<void> updateActivity({
    required String habitId,
    required String activityId,
    String? activityType,
    String? value,
    String? unit,
    String? note,
  }) async {
    state = state.copyWith(isUpdating: true, error: null);
    try {
      final updatedActivity = await _service.updateActivity(
        habitId: habitId,
        activityId: activityId,
        activityType: activityType,
        value: value,
        unit: unit,
        note: note,
      );

      final updatedActivities = state.activities.map((activity) {
        return activity.id == activityId ? updatedActivity : activity;
      }).toList();

      state = state.copyWith(
        activities: updatedActivities,
        isUpdating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: e.toString(),
      );
    }
  }

  // Clear activities
  void clearActivities() {
    state = ActivityState();
  }
}

// Providers
final activitiesNotifierProvider =
    StateNotifierProvider<ActivitiesNotifier, ActivityState>((ref) {
  final habitService = ref.watch(habitServiceProvider);
  return ActivitiesNotifier(habitService);
});

// Convenience provider to get activities for a specific habit and date
final activitiesForHabitProvider =
    FutureProvider.family<List<Activity>, (String habitId, DateTime date)>(
        (ref, params) async {
  final habitService = ref.watch(habitServiceProvider);
  return habitService.getAllActivities(
    habitId: params.$1,
    date: params.$2,
  );
});
