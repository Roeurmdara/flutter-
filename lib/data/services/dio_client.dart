import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import 'secure_storage_service.dart';

/// HTTP Client using Dio with interceptors for auth token management
/// Automatically adds Authorization header to all requests
class DioClient {
  final Dio _dio;
  final SecureStorageService _secureStorage;
  static Future<String?>? _refreshFuture;

  static const String _baseUrl = AppConstants.baseUrl;

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
          debugPrint(
            'DioClient Request: ${options.method} ${options.path} - '
            'Authorization: ${token != null && token.isNotEmpty ? 'Bearer ***' : 'None'}',
          );
          return handler.next(options);
        },
        onResponse: (response, handler) async {
          if (_shouldRefresh(response)) {
            final retryResponse =
                await _refreshAndRetry(response.requestOptions);
            if (retryResponse != null) {
              return handler.resolve(retryResponse);
            }
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;
            if (!_isAuthRequest(requestOptions.path) &&
                requestOptions.extra['authRetry'] != true) {
              final retryResponse = await _refreshAndRetry(requestOptions);
              if (retryResponse != null) {
                return handler.resolve(retryResponse);
              }
            }
            _secureStorage.clearAuthData();
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// Get the Dio instance for custom requests
  Dio get dio => _dio;

  bool _shouldRefresh(Response<dynamic> response) {
    final alreadyRetried = response.requestOptions.extra['authRetry'] == true;
    return response.statusCode == 401 &&
        !alreadyRetried &&
        !_isAuthRequest(response.requestOptions.path);
  }

  bool _isAuthRequest(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout');
  }

  Future<Response<dynamic>?> _refreshAndRetry(
    RequestOptions requestOptions,
  ) async {
    final refreshToken = await _secureStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _secureStorage.clearAuthData();
      return null;
    }

    try {
      final accessToken = await _refreshAccessToken(refreshToken);
      if (accessToken == null) {
        await _secureStorage.clearAuthData();
        return null;
      }

      requestOptions.headers['Authorization'] = 'Bearer $accessToken';
      requestOptions.extra['authRetry'] = true;
      return _dio.fetch<dynamic>(requestOptions);
    } catch (_) {
      await _secureStorage.clearAuthData();
      return null;
    }
  }

  Future<String?> _refreshAccessToken(String refreshToken) {
    final currentRefresh = _refreshFuture;
    if (currentRefresh != null) {
      return currentRefresh;
    }

    _refreshFuture = _performRefresh(refreshToken);
    return _refreshFuture!.whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _performRefresh(String refreshToken) async {
    final refreshDio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    final refreshResponse = await refreshDio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(contentType: Headers.jsonContentType),
    );

    if (refreshResponse.statusCode == null ||
        refreshResponse.statusCode! < 200 ||
        refreshResponse.statusCode! >= 300 ||
        refreshResponse.data == null) {
      return null;
    }

    final data = refreshResponse.data!['data'];
    if (data is! Map<String, dynamic>) {
      return null;
    }

    final tokens = data['tokens'];
    final accessToken = tokens is Map<String, dynamic>
        ? tokens['access_token'] as String?
        : data['access_token'] as String?;
    final newRefreshToken = tokens is Map<String, dynamic>
        ? tokens['refresh_token'] as String?
        : data['refresh_token'] as String?;

    if (accessToken == null || accessToken.isEmpty) {
      return null;
    }

    await _secureStorage.saveAccessToken(accessToken);
    if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
      await _secureStorage.saveRefreshToken(newRefreshToken);
    }

    return accessToken;
  }

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
