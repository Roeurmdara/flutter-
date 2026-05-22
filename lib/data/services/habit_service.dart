import 'package:dio/dio.dart';
import '../models/habit_model.dart';

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
    int perPage = 10,
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
    DateTime? startDate,
    DateTime? endDate,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (frequencyType != null) data['frequency_type'] = frequencyType;
      if (frequencyConfig != null) data['frequency_config'] = frequencyConfig;
      if (startDate != null) data['start_date'] = startDate.toIso8601String();
      if (endDate != null) data['end_date'] = endDate.toIso8601String();
      if (status != null) data['status'] = status;

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

  // Mark habit as done
  Future<void> markHabitAsDone(String habitId, DateTime date) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/habits/$habitId/complete',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to mark habit as done');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Unmark habit as done
  Future<void> unmarkHabitAsDone(String habitId, DateTime date) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/habits/$habitId/uncomplete',
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to unmark habit');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      final response = await _dio.delete('$_baseUrl/habits/$habitId');

      if (response.statusCode != 200) {
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
      totalPages: json['totalPages'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );
  }
}
