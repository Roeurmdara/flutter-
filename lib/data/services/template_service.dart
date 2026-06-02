import 'package:dio/dio.dart';
import '../models/habit_template_model.dart';
import '../../core/constants/app_constants.dart';

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
    } catch (e) {
      print('Error fetching templates: $e');
      return [];
    }
  }

  // Fetch templates by category
  Future<List<HabitTemplate>> fetchTemplatesByCategory(String category) async {
    try {
      final response = await dio.get(
        '${AppConstants.baseUrl}/templates',
        queryParameters: {
          'category_id': category
        }, // Changed from 'category' to 'category_id'
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
    } catch (e) {
      print('Error fetching templates by category: $e');
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
    } catch (e) {
      print('Error fetching template: $e');
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
    } catch (e) {
      print('Error updating template: $e');
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
    } catch (e) {
      print('Error deleting template: $e');
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
    } catch (e) {
      print('Error creating template: $e');
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
    } catch (e) {
      print('Error incrementing template usage: $e');
    }
  }
}
