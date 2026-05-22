import 'package:dio/dio.dart';
import '../models/habit_category_model.dart';
import '../models/discover_template_model.dart';

class HabitCategoryService {
  static const String _baseUrl =
      'https://habit-api.rattanakmony.com/api/v1/categories';

  final Dio _dio;

  HabitCategoryService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch all categories
  Future<List<HabitCategory>> getCategories() async {
    try {
      final response = await _dio.get(
        _baseUrl,
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> categoriesData =
            data['data'] as List<dynamic>? ?? [];

        return categoriesData
            .map((json) => HabitCategory.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch categories: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetch templates for a specific category
  Future<List<DiscoverTemplate>> getCategoryTemplates(String categoryId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$categoryId/templates',
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> templatesData =
            data['data'] as List<dynamic>? ?? [];

        return templatesData
            .map((json) =>
                DiscoverTemplate.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch templates: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching templates: $e');
    }
  }
}
