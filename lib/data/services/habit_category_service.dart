import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';
import '../models/habit_category_model.dart';
import '../models/discover_template_model.dart';

class HabitCategoryService {
  static const String _baseUrl =
      'https://habit-api.rattanakmony.com/api/v1/categories';

  final Dio _dio;

  HabitCategoryService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 30),
                validateStatus: (status) => status != null && status < 500,
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    // Add additional logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print(
              '[HabitCategoryService] Request: ${options.method} ${options.uri}');
          print('[HabitCategoryService] Headers: ${options.headers}');
          return handler.next(options);
        },
        onError: (error, handler) {
          print(
              '[HabitCategoryService] Interceptor Error - Type: ${error.type}');
          print('[HabitCategoryService] Error Message: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  /// Fetch all categories
  Future<List<HabitCategory>> getCategories() async {
    try {
      print('[HabitCategoryService] Fetching categories from: $_baseUrl');

      final response = await _dio.get(
        _baseUrl,
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print('[HabitCategoryService] Response status: ${response.statusCode}');

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
    } on SocketException catch (e) {
      print('[HabitCategoryService] Network error: ${e.message}');
      throw Exception('Network error: No internet connection - ${e.message}');
    } on TimeoutException catch (e) {
      print('[HabitCategoryService] Timeout error: ${e.message}');
      throw Exception('Connection timeout: Server took too long to respond');
    } on DioException catch (e) {
      print(
          '[HabitCategoryService] Dio error - Type: ${e.type}, Message: ${e.message}');
      print('[HabitCategoryService] Response: ${e.response?.statusCode}');

      final String errorMessage = _getDetailedErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      print('[HabitCategoryService] Unexpected error: $e');
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetch templates for a specific category
  /// Returns empty list if fetch fails (instead of throwing)
  Future<List<DiscoverTemplate>> getCategoryTemplates(String categoryId) async {
    try {
      const templatesUrl =
          'https://habit-api.rattanakmony.com/api/v1/templates';
      print(
          '[HabitCategoryService] ========== STARTING TEMPLATE FETCH ==========');
      print(
          '[HabitCategoryService] Fetching templates for category: $categoryId');
      print('[HabitCategoryService] Base URL: $templatesUrl');

      final response = await _dio.get(
        templatesUrl,
        queryParameters: {
          'category_id': categoryId,
          'page': 1,
          'per_page': 100,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print(
          '[HabitCategoryService] Template response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> templatesData =
            data['data'] as List<dynamic>? ?? [];

        print(
            '[HabitCategoryService] ✓ Found ${templatesData.length} templates');
        print(
            '[HabitCategoryService] ========== TEMPLATE FETCH SUCCESS ==========');

        return templatesData
            .map((json) =>
                DiscoverTemplate.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        print(
            '[HabitCategoryService] ✗ Bad status code: ${response.statusCode}');
        print(
            '[HabitCategoryService] ========== RETURNING EMPTY LIST ==========');
        return []; // Return empty instead of throwing
      }
    } on SocketException catch (e) {
      print('[HabitCategoryService] ✗ SocketException: ${e.message}');
      print(
          '[HabitCategoryService] ========== RETURNING EMPTY LIST ==========');
      return []; // Return empty instead of throwing
    } on TimeoutException catch (e) {
      print('[HabitCategoryService] ✗ TimeoutException: ${e.message}');
      print(
          '[HabitCategoryService] ========== RETURNING EMPTY LIST ==========');
      return []; // Return empty instead of throwing
    } on DioException catch (e) {
      print('[HabitCategoryService] ========== DIO EXCEPTION ==========');
      print('[HabitCategoryService] Type: ${e.type}');
      print('[HabitCategoryService] Message: ${e.message}');
      print('[HabitCategoryService] Status Code: ${e.response?.statusCode}');
      print('[HabitCategoryService] Error: ${e.error}');
      print(
          '[HabitCategoryService] ========== RETURNING EMPTY LIST ==========');
      return []; // Return empty instead of throwing
    } catch (e) {
      print('[HabitCategoryService] ✗ Unexpected error: $e');
      print(
          '[HabitCategoryService] ========== RETURNING EMPTY LIST ==========');
      return []; // Return empty instead of throwing
    }
  }

  /// Test the templates endpoint connectivity
  Future<bool> testTemplatesConnection() async {
    try {
      print('[HabitCategoryService] Testing templates endpoint...');
      const testUrl =
          'https://habit-api.rattanakmony.com/api/v1/templates?page=1&per_page=1';

      final response = await _dio.get(testUrl);
      print(
          '[HabitCategoryService] Test response status: ${response.statusCode}');

      return response.statusCode == 200;
    } catch (e) {
      print('[HabitCategoryService] Test failed: $e');
      return false;
    }
  }

  /// Helper method to get detailed error messages
  String _getDetailedErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout: Server did not respond in time';
      case DioExceptionType.sendTimeout:
        return 'Send timeout: Could not send request to server';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout: No response from server';
      case DioExceptionType.badResponse:
        return 'Bad response: Server returned ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request was cancelled';
      case DioExceptionType.connectionError:
        return 'Connection error: Check internet connection or CORS settings';
      case DioExceptionType.badCertificate:
        return 'SSL certificate error: The server certificate is invalid';
      case DioExceptionType.unknown:
      default:
        return 'Unknown error: ${error.message}. The server may be unreachable or there may be a CORS issue.';
    }
  }
}
