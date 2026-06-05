import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';
import '../models/habit_category_model.dart';
import '../models/discover_template_model.dart';
import 'secure_storage_service.dart';

class HabitCategoryService {
  static const String _baseUrl =
      'https://habit-api.rattanakmony.com/api/v1/categories';

  final Dio _dio;
  final SecureStorageService _secureStorage;

  HabitCategoryService({Dio? dio, SecureStorageService? secureStorage})
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
            ),
        _secureStorage = secureStorage ?? SecureStorageService();

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
    } on SocketException catch (e) {
      throw Exception('Network error: No internet connection - ${e.message}');
    } on TimeoutException catch (_) {
      throw Exception('Connection timeout: Server took too long to respond');
    } on DioException catch (e) {
      final String errorMessage = _getDetailedErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching categories: $e');
    }
  }

  /// Fetch templates for a specific category
  Future<List<DiscoverTemplate>> getCategoryTemplates(String categoryId) async {
    try {
      const templatesUrl =
          'https://habit-api.rattanakmony.com/api/v1/templates';

      final response = await _dio.get(
        templatesUrl,
        queryParameters: {
          'category_id': categoryId,
          'page': 1,
          'per_page': 100,
        },
        options: await _authOptions(
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
        throw Exception(_extractResponseMessage(response));
      }
    } on SocketException catch (e) {
      throw Exception('Network error: No internet connection - ${e.message}');
    } on TimeoutException catch (_) {
      throw Exception('Connection timeout: Server took too long to respond');
    } on DioException catch (e) {
      final String errorMessage = _getDetailedErrorMessage(e);
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Error fetching templates: $e');
    }
  }

  /// Test the templates endpoint connectivity
  Future<bool> testTemplatesConnection() async {
    try {
      const testUrl =
          'https://habit-api.rattanakmony.com/api/v1/templates?page=1&per_page=1';

      final response = await _dio.get(testUrl, options: await _authOptions());

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<Options> _authOptions({
    String? contentType,
    bool? followRedirects,
    ValidateStatus? validateStatus,
  }) async {
    final headers = <String, dynamic>{};
    final token = await _secureStorage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return Options(
      headers: headers,
      contentType: contentType,
      followRedirects: followRedirects,
      validateStatus: validateStatus,
    );
  }

  String _extractResponseMessage(Response response) {
    final data = response.data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map && error['message'] != null) {
        return error['message'].toString();
      }
      if (data['message'] != null) return data['message'].toString();
    }
    return 'Request failed: HTTP ${response.statusCode}';
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
      default:
        return 'Unknown error: ${error.message}. The server may be unreachable or there may be a CORS issue.';
    }
  }
}
