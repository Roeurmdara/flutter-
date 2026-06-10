import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../models/auth_models.dart';
import 'secure_storage_service.dart';
import '../../presentation/widgets/oauth_webview.dart';

class AuthService {
  static const String _baseUrl =
      'https://habit-api.rattanakmony.com/api/v1/auth';
  static const String _apiBaseUrl = 'https://habit-api.rattanakmony.com/api/v1';

  final Dio _dio;
  final SecureStorageService _secureStorage;

  AuthService({
    Dio? dio,
    SecureStorageService? secureStorage,
  })  : _dio = dio ?? Dio(),
        _secureStorage = secureStorage ?? SecureStorageService();

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
  /// Opens an embedded webview for OAuth authentication and handles callback
  Future<AuthResponse> socialLogin(String provider, BuildContext context) async {
    try {
      // 1. Open WebView for OAuth authentication
      final authUrl = '$_apiBaseUrl/auth/social/$provider';

      final jsonResult = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (context) => OAuthWebView(
            url: authUrl,
            callbackUrl: '$_apiBaseUrl/auth/social/$provider/callback',
            providerName: provider == 'google' ? 'Google' : 'GitHub',
          ),
          fullscreenDialog: true,
        ),
      );

      if (jsonResult == null || jsonResult.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'Sign in cancelled',
          status: 400,
          error: 'User cancelled oauth login',
          errorCode: 'CANCELLED',
        );
      }

      // 2. Parse JSON response
      final decoded = jsonDecode(jsonResult);
      if (decoded is! Map<String, dynamic>) {
        return AuthResponse(
          success: false,
          message: 'Invalid response format from server',
          status: 200,
          error: 'Expected JSON map response',
          errorCode: 'INVALID_RESPONSE',
        );
      }

      final authResponse = AuthResponse.fromJson(decoded);

      // 3. Save tokens securely if successful (check both data.token and data.user.token)
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
      return AuthResponse(
        success: false,
        message: 'An unexpected error occurred: $e',
        status: 500,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Login with Google
  Future<AuthResponse> loginWithGoogle(BuildContext context) async {
    return socialLogin('google', context);
  }

  /// Login with GitHub
  Future<AuthResponse> loginWithGithub(BuildContext context) async {
    return socialLogin('github', context);
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
