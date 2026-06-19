import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../../core/constants/app_constants.dart';
import '../models/auth_models.dart';
import 'secure_storage_service.dart';

class AuthService {
  static const String _baseUrl = '/auth';

  final Dio _dio;
  final SecureStorageService _secureStorage;

  AuthService({
    Dio? dio,
    SecureStorageService? secureStorage,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? SecureStorageService() {
    _dio.options.baseUrl = AppConstants.baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final request = RegisterRequest(
        email: email,
        username: username,
        password: password,
      );

      final response = await _dio.post(
        '$_baseUrl/register',
        data: request.toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // Persist tokens and user data when login succeeds so refresh works
      try {
        final token =
            authResponse.data?.token ?? authResponse.data?.user?.token;
        final refreshToken = authResponse.data?.refreshToken;
        if (authResponse.success && token != null && token.isNotEmpty) {
          await _secureStorage.saveAccessToken(token);
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await _secureStorage.saveRefreshToken(refreshToken);
          }

          if (authResponse.data?.user != null) {
            await _secureStorage.saveUserData(
              userId: authResponse.data!.user!.id,
              email: authResponse.data!.user!.email,
              username: authResponse.data!.user!.username,
            );
          }
        }
      } catch (e) {
        // ignore storage errors here — login still returns success to caller
      }

      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message ?? 'Registration failed',
        status: e.response?.statusCode ?? 500,
        error: e.message,
        errorCode: 'NETWORK_ERROR',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred',
        status: 500,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final request = LoginRequest(
        username: username,
        password: password,
      );

      final response = await _dio.post(
        '$_baseUrl/login',
        data: request.toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 600,
        ),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      await _persistAuthData(authResponse);
      return authResponse;
    } on DioException catch (e) {
      return _authErrorResponse(e, fallbackMessage: 'Login failed');
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred',
        status: 500,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Request password reset
  Future<AuthResponse> requestPasswordReset({
    required String email,
    String? redirectUri,
  }) async {
    try {
      final request = PasswordResetRequest(
        email: email,
        redirectUri: redirectUri,
      );

      final response = await _dio.post(
        '$_baseUrl/password/reset-request',
        data: request.toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return authResponse;
    } on DioException catch (e) {
      return AuthResponse(
        success: false,
        message: e.message ?? 'Password reset request failed',
        status: e.response?.statusCode ?? 500,
        error: e.message,
        errorCode: 'NETWORK_ERROR',
      );
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred',
        status: 500,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Social login with Google or GitHub
  /// Opens a secure system browser (Custom Tab) dynamically for OAuth authentication and handles callback redirect.
  Future<AuthResponse> socialLogin(String provider) async {
    try {
      debugPrint(
          "AuthService: Requesting dynamic OAuth redirect URL from backend for $provider...");

      // 1. Fetch Keycloak redirect URL dynamically from Laravel API
      final urlResponse = await _dio.get('$_baseUrl/social/$provider/url');
      if (urlResponse.statusCode != 200 || urlResponse.data == null) {
        return AuthResponse(
          success: false,
          message: 'Failed to retrieve social auth URL from backend',
          status: urlResponse.statusCode ?? 500,
          error: 'URL retrieval status code: ${urlResponse.statusCode}',
          errorCode: 'URL_RETRIEVAL_FAILED',
        );
      }

      final urlData = urlResponse.data as Map<String, dynamic>;
      final dynamicAuthUrl = urlData['data']?['redirect_url']?.toString();

      if (dynamicAuthUrl == null || dynamicAuthUrl.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Dynamic auth redirect URL was empty',
          status: 500,
          error: 'Missing redirect_url in API response',
          errorCode: 'EMPTY_AUTH_URL',
        );
      }

      debugPrint("AuthService: Retrieved dynamic auth URL: $dynamicAuthUrl");
      debugPrint("AuthService: Launching FlutterWebAuth2...");

      // 2. Open browser tab using flutter_web_auth_2
      final result = await FlutterWebAuth2.authenticate(
        url: dynamicAuthUrl,
        callbackUrlScheme: 'com.habit.app',
      );

      debugPrint("AuthService: Received callback redirect URL: $result");

      // 3. Extract authorization code and state from URL
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];

      if (code == null || state == null) {
        return AuthResponse(
          success: false,
          message:
              'Failed to complete authentication: Callback redirect missing code or state.',
          status: 400,
          error: 'Callback URL query parameters: code=$code, state=$state',
          errorCode: 'INVALID_CALLBACK',
        );
      }

      debugPrint(
          "AuthService: Exchanging code and state with backend callback...");

      // 4. Exchange code and state for app JWT and user data
      final callbackResponse = await _dio.get(
        '$_baseUrl/social/$provider/callback',
        queryParameters: {
          'code': code,
          'state': state,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      if (callbackResponse.statusCode != 200 || callbackResponse.data == null) {
        return AuthResponse(
          success: false,
          message: 'Backend failed to exchange social authorization code',
          status: callbackResponse.statusCode ?? 500,
          error: 'Exchange failed with status: ${callbackResponse.statusCode}',
          errorCode: 'EXCHANGE_FAILED',
        );
      }

      final authResponse = AuthResponse.fromJson(
        callbackResponse.data as Map<String, dynamic>,
      );

      debugPrint(
          "AuthService: Exchange successful. Success state: ${authResponse.success}");

      // 5. Save tokens securely if successful (check both data.token and data.user.token)
      final token = authResponse.data?.token ?? authResponse.data?.user?.token;
      if (authResponse.success && token != null && token.isNotEmpty) {
        await _secureStorage.saveAccessToken(token);

        final refreshToken = authResponse.data?.refreshToken;
        if (refreshToken != null && refreshToken.isNotEmpty) {
          await _secureStorage.saveRefreshToken(refreshToken);
        }

        if (authResponse.data?.user != null) {
          await _secureStorage.saveUserData(
            userId: authResponse.data!.user!.id,
            email: authResponse.data!.user!.email,
            username: authResponse.data!.user!.username,
          );
        }
      }

      return authResponse;
    } catch (e) {
      debugPrint("AuthService: Exception during social login: $e");

      String errorCode = 'UNKNOWN_ERROR';
      String message = 'An unexpected error occurred: $e';

      if (e.toString().contains('UserCancelledException')) {
        errorCode = 'CANCELLED';
        message = 'Sign in cancelled';
      } else if (e.toString().contains('PlatformException')) {
        errorCode = 'PLATFORM_ERROR';
        message =
            'Authentication failed. Please check your browser connection.';
      }

      return AuthResponse(
        success: false,
        message: message,
        status: 500,
        error: e.toString(),
        errorCode: errorCode,
      );
    }
  }

  /// Login with Google
  Future<AuthResponse> loginWithGoogle([BuildContext? context]) async {
    return socialLogin('google');
  }

  /// Login with GitHub
  Future<AuthResponse> loginWithGithub([BuildContext? context]) async {
    return socialLogin('github');
  }

  /// Logout and clear auth data
  Future<void> logout() async {
    await _secureStorage.clearAuthData();
  }

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.saveAccessToken(token);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.saveRefreshToken(token);
  }

  Future<void> _persistAuthData(AuthResponse authResponse) async {
    final token = authResponse.data?.token ?? authResponse.data?.user?.token;
    final refreshToken = authResponse.data?.refreshToken;
    if (!authResponse.success || token == null || token.isEmpty) {
      return;
    }

    await _secureStorage.saveAccessToken(token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _secureStorage.saveRefreshToken(refreshToken);
    }

    final user = authResponse.data?.user;
    if (user != null) {
      await _secureStorage.saveUserData(
        userId: user.id,
        email: user.email,
        username: user.username,
      );
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _secureStorage.isLoggedIn();
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return _secureStorage.getAccessToken();
  }

  AuthResponse _authErrorResponse(
    DioException error, {
    required String fallbackMessage,
  }) {
    final status = error.response?.statusCode ?? 500;
    final data = error.response?.data;
    final message = status == 503
        ? 'Authentication server is temporarily unavailable. Please try again later.'
        : _extractErrorMessage(data) ?? error.message ?? fallbackMessage;

    return AuthResponse(
      success: false,
      message: message,
      status: status,
      error: message,
      errorCode: status == 503 ? 'AUTH_SERVER_UNAVAILABLE' : 'NETWORK_ERROR',
    );
  }

  String? _extractErrorMessage(Object? data) {
    if (data is! Map) return null;
    final error = data['error'];
    if (error is Map && error['message'] != null) {
      return error['message'].toString();
    }
    if (data['message'] != null) return data['message'].toString();
    return null;
  }
}
