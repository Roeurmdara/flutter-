import 'package:dio/dio.dart';
import '../models/profile_model.dart';

class UserProfileService {
  static const String _baseUrl =
      'https://habit-api.rattanakmony.com/api/v1/users';

  final Dio _dio;
  String? _authToken;

  UserProfileService({Dio? dio}) : _dio = dio ?? Dio();

  /// Set authentication token for subsequent requests
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Get the current authentication token
  String? getAuthToken() => _authToken;

  /// Fetch current user profile
  Future<ProfileResponse> getUserProfile() async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        return ProfileResponse(
          success: false,
          message: 'A valid Bearer token is required.',
          status: 401,
          error: 'AUTH_TOKEN_MISSING',
          errorCode: 'AUTH_TOKEN_MISSING',
        );
      }

      final response = await _dio.get(
        '$_baseUrl/me',
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final profileResponse = ProfileResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return profileResponse;
    } on DioException catch (e) {
      return ProfileResponse(
        success: false,
        message: e.message ?? 'Failed to fetch user profile',
        status: e.response?.statusCode ?? 500,
        error: e.message,
        errorCode: 'NETWORK_ERROR',
      );
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'An unexpected error occurred',
        status: 500,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Update user profile
  Future<ProfileResponse> updateUserProfile({
    required String username,
    String? avatarUrl,
    String? bio,
  }) async {
    try {
      if (_authToken == null || _authToken!.isEmpty) {
        return ProfileResponse(
          success: false,
          message: 'A valid Bearer token is required.',
          status: 401,
          error: 'AUTH_TOKEN_MISSING',
          errorCode: 'AUTH_TOKEN_MISSING',
        );
      }

      final request = UserProfileUpdateRequest(
        username: username,
        avatarUrl: avatarUrl,
        bio: bio,
      );

      final response = await _dio.put(
        '$_baseUrl/me',
        data: request.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $_authToken',
            'Content-Type': 'application/json',
          },
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final profileResponse = ProfileResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return profileResponse;
    } on DioException catch (e) {
      return ProfileResponse(
        success: false,
        message: e.message ?? 'Failed to update user profile',
        status: e.response?.statusCode ?? 500,
        error: e.message,
        errorCode: 'NETWORK_ERROR',
      );
    } catch (e) {
      return ProfileResponse(
        success: false,
        message: 'An unexpected error occurred',
        status: 500,
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }
}
