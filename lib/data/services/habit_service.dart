import 'package:dio/dio.dart';
import '../models/habit_model.dart';
import '../models/activity_model.dart';

class HabitService {
  final Dio _dio;
  static const String _baseUrl = 'https://habit-api.rattanakmony.com/api/v1';

  HabitService(this._dio);

  // Create a new habit
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
    try {
      final response = await _dio.post(
        '$_baseUrl/habits',
        data: {
          'category_id': categoryId,
          'title': title,
          'description': description,
          'status': 'created',
          'frequency_type': frequencyType,
          'frequency_config': frequencyConfig,
          'goal_type': goalType,
          'target_value': targetValue,
          'target_unit': targetUnit,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate?.toIso8601String(),
          'visibility': visibility,
          if (emoji != null) 'emoji': emoji,
          if (colorHex != null) 'color_hex': colorHex,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Habit.fromJson(response.data['data']);
      }
      throw Exception('Failed to create habit');
    } catch (e) {
      rethrow;
    }
  }

  // Get all habits with filtering
  Future<HabitListResponse> getHabits({
    int page = 1,
    int perPage = 100,
    String? status,
    String? categoryId,
  }) async {
    try {
      final params = {
        'page': page,
        'per_page': perPage,
        if (status != null) 'status': status,
        if (categoryId != null) 'category_id': categoryId,
      };

      final response = await _dio.get(
        '$_baseUrl/habits',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        return HabitListResponse.fromJson(response.data);
      }
      throw Exception('Failed to fetch habits');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Habit>> getAllHabits({
    String? status,
    String? categoryId,
  }) async {
    final habits = <Habit>[];
    var page = 1;
    var hasNext = true;

    while (hasNext) {
      final response = await getHabits(
        page: page,
        perPage: 100,
        status: status,
        categoryId: categoryId,
      );
      habits.addAll(response.data);
      hasNext = response.meta.hasNext && response.data.isNotEmpty;
      page += 1;
    }

    return habits;
  }

  // Get a specific habit
  Future<Habit> getHabit(String habitId) async {
    try {
      final response = await _dio.get('$_baseUrl/habits/$habitId');

      if (response.statusCode == 200) {
        return Habit.fromJson(response.data['data']);
      }
      throw Exception('Failed to fetch habit');
    } catch (e) {
      rethrow;
    }
  }

  // Update a habit
  Future<Habit> updateHabit(
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
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (frequencyType != null) data['frequency_type'] = frequencyType;
      if (frequencyConfig != null) data['frequency_config'] = frequencyConfig;
      if (categoryId != null) data['category_id'] = categoryId;
      if (startDate != null) data['start_date'] = startDate.toIso8601String();
      if (endDate != null) data['end_date'] = endDate.toIso8601String();
      if (status != null) data['status'] = status;
      if (emoji != null) data['emoji'] = emoji;
      if (colorHex != null) data['color_hex'] = colorHex;

      final response = await _dio.put(
        '$_baseUrl/habits/$habitId',
        data: data,
      );

      if (response.statusCode == 200) {
        return Habit.fromJson(response.data['data']);
      }
      throw Exception('Failed to update habit');
    } catch (e) {
      rethrow;
    }
  }

  // Mark habit as done - returns updated Habit when available
  Future<Habit?> markHabitAsDone(String habitId, DateTime date) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/habits/$habitId/mark-done',
        data: {
          'date': _formatDate(date),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data'] as Map<String, dynamic>
            : null;
        if (data != null) return Habit.fromJson(data);
        // If the endpoint did not return the habit, fetch it
        return await getHabit(habitId);
      }

      // Treat 204 as success but no body
      if (response.statusCode == 204) {
        return await getHabit(habitId);
      }

      throw Exception('Failed to mark habit as done');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      // If the endpoint is not found, treat as non-fatal: the app will
      // keep optimistic local state and persist it. Re-throw other errors.
      if (statusCode == 404) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Unmark habit as done - returns updated Habit when available
  Future<Habit?> unmarkHabitAsDone(String habitId, DateTime date) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/habits/$habitId/mark-done',
        data: {
          'date': _formatDate(date),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data is Map && response.data['data'] != null
            ? response.data['data'] as Map<String, dynamic>
            : null;
        if (data != null) return Habit.fromJson(data);
        return await getHabit(habitId);
      }

      if (response.statusCode == 204) {
        return await getHabit(habitId);
      }

      throw Exception('Failed to unmark habit');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 404) {
        return null;
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  // ─── ACTIVITY METHODS ───────────────────────────────────────────────────

  // Get activities for a habit by date
  Future<ActivityListResponse> getActivities({
    required String habitId,
    required DateTime date,
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final params = {
        'page': page,
        'per_page': perPage,
        'date': _formatDate(date),
      };

      final response = await _dio.get(
        '$_baseUrl/habits/$habitId/activities',
        queryParameters: params,
      );

      if (response.statusCode == 200) {
        return ActivityListResponse.fromJson(response.data);
      }
      throw Exception('Failed to fetch activities');
    } catch (e) {
      rethrow;
    }
  }

  // Get all activities for a habit
  Future<List<Activity>> getAllActivities({
    required String habitId,
    required DateTime date,
  }) async {
    final activities = <Activity>[];
    var page = 1;
    var hasNext = true;

    while (hasNext) {
      final response = await getActivities(
        habitId: habitId,
        date: date,
        page: page,
        perPage: 100,
      );
      activities.addAll(response.data);
      hasNext = response.meta.hasNext && response.data.isNotEmpty;
      page += 1;
    }

    return activities;
  }

  // Create a new activity for a habit
  Future<Activity> createActivity({
    required String habitId,
    required String activityType,
    required String value,
    required String unit,
    required DateTime settlementPeriodDate,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/habits/$habitId/activities',
        data: {
          'activity_type': activityType,
          'value': value,
          'unit': unit,
          'settlement_period_date': settlementPeriodDate.toIso8601String(),
          'logged_at': DateTime.now().toIso8601String(),
          if (note != null) 'note': note,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Activity.fromJson(response.data['data']);
      }
      throw Exception('Failed to create activity');
    } catch (e) {
      rethrow;
    }
  }

  // Mark activity as complete
  Future<Activity> markActivityAsComplete(
    String habitId,
    String activityId,
  ) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/habits/$habitId/activities/$activityId/mark-done',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Activity.fromJson(response.data['data']);
      }
      throw Exception('Failed to mark activity as complete');
    } catch (e) {
      rethrow;
    }
  }

  // Unmark activity as complete
  Future<Activity> unmarkActivityAsComplete(
    String habitId,
    String activityId,
  ) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/habits/$habitId/activities/$activityId/mark-done',
      );

      if (response.statusCode == 200 ||
          response.statusCode == 201 ||
          response.statusCode == 204) {
        // If 204, reconstruct the Activity object
        if (response.statusCode == 204) {
          throw Exception('Activity unmarked but no data returned');
        }
        return Activity.fromJson(response.data['data']);
      }
      throw Exception('Failed to unmark activity');
    } catch (e) {
      rethrow;
    }
  }

  // Update an activity
  Future<Activity> updateActivity({
    required String habitId,
    required String activityId,
    String? activityType,
    String? value,
    String? unit,
    String? note,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (activityType != null) data['activity_type'] = activityType;
      if (value != null) data['value'] = value;
      if (unit != null) data['unit'] = unit;
      if (note != null) data['note'] = note;

      final response = await _dio.put(
        '$_baseUrl/habits/$habitId/activities/$activityId',
        data: data,
      );

      if (response.statusCode == 200) {
        return Activity.fromJson(response.data['data']);
      }
      throw Exception('Failed to update activity');
    } catch (e) {
      rethrow;
    }
  }

  // Delete an activity
  Future<void> deleteActivity(String habitId, String activityId) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/habits/$habitId/activities/$activityId',
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception('Failed to delete activity');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      final response = await _dio.delete('$_baseUrl/habits/$habitId');

      if (response.statusCode != 200 &&
          response.statusCode != 201 &&
          response.statusCode != 204) {
        throw Exception('Failed to delete habit');
      }
    } catch (e) {
      rethrow;
    }
  }
}

class HabitListResponse {
  final bool success;
  final String message;
  final int status;
  final List<Habit> data;
  final HabitMeta meta;

  HabitListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.data,
    required this.meta,
  });

  factory HabitListResponse.fromJson(Map<String, dynamic> json) {
    return HabitListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Habit.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: HabitMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class HabitMeta {
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  HabitMeta({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory HabitMeta.fromJson(Map<String, dynamic> json) {
    return HabitMeta(
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages:
          (json['totalPages'] as int?) ?? (json['last_page'] as int?) ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );
  }
}
