import 'package:dio/dio.dart';
import 'secure_storage_service.dart';

/// HTTP Client using Dio with interceptors for auth token management
/// Automatically adds Authorization header to all requests
class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;

  static const String _baseUrl = 'https://habit-api.rattanakmony.com/api/v1';

  DioClient({
    Dio? dio,
    SecureStorageService? secureStorage,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    _setupInterceptors();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.validateStatus = (status) {
      // Accept all status codes to handle them in service
      return true;
    };
  }

  /// Setup Dio interceptors for auth and error handling
  void _setupInterceptors() {
    // Request interceptor: Add auth token to headers
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        // Error interceptor: Handle auth errors
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired - could implement refresh token logic here
          }
          return handler.next(error);
        },
      ),
    );

    // Add logging interceptor for debugging network requests
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (obj) {
          // ignore: avoid_print
          print(obj);
        },
      ),
    );
  }

  /// Get the Dio instance for custom requests
  Dio get dio => _dio;

  /// Helper method for GET requests
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
    );
  }

  /// Helper method for POST requests
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Helper method for PUT requests
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  /// Helper method for DELETE requests
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }
}
