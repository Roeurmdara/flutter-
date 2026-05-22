import 'package:dio/dio.dart';
import '../models/auth_models.dart';

class AuthService {
  static const String _baseUrl =
      'https://habit-api.rattanakmony.com/api/v1/auth';

  final Dio _dio;

  AuthService({Dio? dio}) : _dio = dio ?? Dio();

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
}
