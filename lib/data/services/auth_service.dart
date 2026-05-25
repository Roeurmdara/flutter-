import 'package:dio/dio.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import '../models/auth_models.dart';
import 'secure_storage_service.dart';

class AuthService {
  static const String _baseUrl =
      'https://habit-api.rattanakmony.com/api/v1/auth';
  static const String _apiBaseUrl = 'https://habit-api.rattanakmony.com/api/v1';
  static const String _redirectScheme = 'myapp';

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
        message: e.message ?? 'Login failed',
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

  /// Request password reset
  Future<AuthResponse> requestPasswordReset({
    required String email,
    required String redirectUri,
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
  /// Opens browser for OAuth authentication and handles callback
  Future<AuthResponse> socialLogin(String provider) async {
    try {
      // 1. Open browser for OAuth authentication
      final authUrl = '$_apiBaseUrl/auth/social/$provider';

      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: _redirectScheme,
      );

      // 2. Parse callback URL to extract code and state
      final uri = Uri.parse(result);
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];

      if (code == null || code.isEmpty) {
        return AuthResponse(
          success: false,
          message: 'No authorization code received',
          status: 400,
          error: 'Missing authorization code',
          errorCode: 'NO_AUTH_CODE',
        );
      }

      // 3. Exchange code for tokens via backend callback endpoint
      final response = await _dio.get(
        '$_apiBaseUrl/auth/social/$provider/callback',
        queryParameters: {
          'code': code,
          if (state != null) 'state': state,
        },
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200) {
        return AuthResponse(
          success: false,
          message: 'Authentication failed: ${response.statusMessage}',
          status: response.statusCode ?? 500,
          error: 'OAuth callback failed',
          errorCode: 'OAUTH_FAILED',
        );
      }

      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      // 4. Save tokens securely if successful
      // ✅ Replace with this
      if (authResponse.success && authResponse.data?.token != null) {
        await _secureStorage.saveAccessToken(
          authResponse.data!.token!,
        );

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
      // Handle specific errors
      String errorCode = 'UNKNOWN_ERROR';
      String message = 'An unexpected error occurred';

      if (e.toString().contains('UserCancelledException')) {
        errorCode = 'CANCELLED';
        message = 'Sign in cancelled';
      } else if (e.toString().contains('PlatformException')) {
        errorCode = 'PLATFORM_ERROR';
        message = 'Authentication failed. Please try again.';
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
  Future<AuthResponse> loginWithGoogle() async {
    return socialLogin('google');
  }

  /// Login with GitHub
  Future<AuthResponse> loginWithGithub() async {
    return socialLogin('github');
  }

  /// Logout and clear auth data
  Future<void> logout() async {
    await _secureStorage.clearAuthData();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return _secureStorage.isLoggedIn();
  }

  /// Get current access token
  Future<String?> getAccessToken() async {
    return _secureStorage.getAccessToken();
  }
}
