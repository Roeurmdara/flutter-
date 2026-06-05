import 'package:dio/dio.dart';
import 'dart:developer' as developer;

import '../models/habit_template_model.dart';
import '../../core/constants/app_constants.dart';

// Response model for paginated templates
class TemplateListResponse {
  final List<HabitTemplate> templates;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  TemplateListResponse({
    required this.templates,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.perPage = 10,
  });

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}

class TemplateService {
  final Dio dio;

  TemplateService(this.dio);

  // Fetch all templates
  Future<List<HabitTemplate>> fetchTemplates() async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/templates',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((t) => HabitTemplate.fromJson(t)).toList();
        }
        if (data is List) {
          return data.map((t) => HabitTemplate.fromJson(t)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      developer.log('Error fetching templates', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Fetch templates by category with pagination
  Future<TemplateListResponse> fetchTemplatesByCategory(
    String categoryId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/templates',
        queryParameters: {
          'category_id': categoryId,
          'page': page,
          'per_page': perPage,
        },
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          final templates = (data['data'] as List? ?? [])
              .map((t) => HabitTemplate.fromJson(t as Map<String, dynamic>))
              .toList();
          final meta = data['meta'] as Map<String, dynamic>? ?? {};
          return TemplateListResponse(
            templates: templates,
            currentPage: meta['current_page'] as int? ?? page,
            lastPage: meta['last_page'] as int? ?? 1,
            total: meta['total'] as int? ?? templates.length,
            perPage: meta['per_page'] as int? ?? perPage,
          );
        }
      }
      return TemplateListResponse(
          templates: [], currentPage: page, lastPage: 1, total: 0);
    } catch (e, stackTrace) {
      developer.log('Error fetching templates by category',
          error: e, stackTrace: stackTrace);
      return TemplateListResponse(
          templates: [], currentPage: page, lastPage: 1, total: 0);
    }
  }

  // Legacy method - fetch all templates by category (no pagination)
  Future<List<HabitTemplate>> fetchTemplatesByCategorySimple(
      String categoryId) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/templates',
        queryParameters: {'category_id': categoryId},
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          final list = data['data'] as List;
          return list.map((t) => HabitTemplate.fromJson(t)).toList();
        }
        if (data is List) {
          return data.map((t) => HabitTemplate.fromJson(t)).toList();
        }
      }
      return [];
    } catch (e, stackTrace) {
      developer.log('Error fetching templates by category',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Fetch single template
  Future<HabitTemplate?> fetchTemplate(String id) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/templates/$id',
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Handle wrapped response format
        if (data is Map && data['data'] != null) {
          return HabitTemplate.fromJson(data['data'] as Map<String, dynamic>);
        }
        // Handle direct data format
        if (data is Map<String, dynamic>) {
          return HabitTemplate.fromJson(data);
        }
      }
      return null;
    } catch (e, stackTrace) {
      developer.log('Error fetching template', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Update template
  Future<HabitTemplate?> updateTemplate(HabitTemplate template) async {
    try {
      final response = await dio.put(
        '${AppConstants.baseUrl}/templates/${template.id}',
        data: template.toJson(),
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        return HabitTemplate.fromJson(response.data);
      }
      return null;
    } catch (e, stackTrace) {
      developer.log('Error updating template', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Delete template
  Future<bool> deleteTemplate(String id) async {
    try {
      final response = await dio.delete(
        '${AppConstants.baseUrl}/templates/$id',
        options: Options(validateStatus: (status) => status! < 500),
      );

      return response.statusCode == 200;
    } catch (e, stackTrace) {
      developer.log('Error deleting template', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  // Create template
  Future<HabitTemplate?> createTemplate(HabitTemplate template) async {
    try {
      final response = await dio.post(
        '${AppConstants.baseUrl}/templates',
        data: template.toJson(),
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return HabitTemplate.fromJson(response.data);
      }
      return null;
    } catch (e, stackTrace) {
      developer.log('Error creating template', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  // Increment template usage
  Future<void> incrementTemplateUsage(String id) async {
    try {
      await dio.post(
        '${AppConstants.baseUrl}/templates/$id/increment-usage',
        options: Options(validateStatus: (status) => status! < 500),
      );
    } catch (e, stackTrace) {
      developer.log('Error incrementing template usage',
          error: e, stackTrace: stackTrace);
    }
  }
}
