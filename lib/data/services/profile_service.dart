import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../models/follower_model.dart';

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

  Future<String?> _getAuthToken() async {
    if (_authToken != null && _authToken!.isNotEmpty) {
      return _authToken;
    }

    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token') ?? prefs.getString('user_token');
    return _authToken;
  }

  /// Fetch current user profile
  Future<ProfileResponse> getUserProfile() async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) {
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
            'Authorization': 'Bearer $authToken',
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
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) {
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
            'Authorization': 'Bearer $authToken',
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

  /// Upload an avatar or media file to the server using the media.upload endpoint.
  /// Returns the uploaded image URL on success, or null on failure.
  Future<String?> uploadAvatar(File file) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) return null;

      final fileName = file.path.split(Platform.pathSeparator).last;
      final form = FormData.fromMap({
        'media': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        'https://habit-api.rattanakmony.com/api/v1/media.upload',
        data: form,
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'multipart/form-data',
          },
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.data is Map && (response.data as Map).containsKey('data')) {
        final data = (response.data as Map)['data'];
        if (data is Map && (data['url'] != null || data['path'] != null)) {
          return data['url'] as String? ?? data['path'] as String?;
        }
      }
      return null;
    } on DioException catch (_) {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Fetch list of followers for the current user
  Future<FollowerListResponse> getFollowers({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) {
        return FollowerListResponse(
          success: false,
          message: 'A valid Bearer token is required.',
          status: 401,
          data: [],
          meta: PaginationMeta(
            page: page,
            size: 0,
            totalElements: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            perPage: perPage,
            total: 0,
            lastPage: 1,
          ),
          error: 'AUTH_TOKEN_MISSING',
          errorCode: 'AUTH_TOKEN_MISSING',
        );
      }

      final response = await _dio.get(
        '$_baseUrl/me/followers',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final followerResponse = FollowerListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return followerResponse;
    } on DioException catch (e) {
      return FollowerListResponse(
        success: false,
        message: e.message ?? 'Failed to fetch followers',
        status: e.response?.statusCode ?? 500,
        data: [],
        meta: PaginationMeta(
          page: page,
          size: 0,
          totalElements: 0,
          totalPages: 0,
          hasNext: false,
          hasPrevious: false,
          perPage: perPage,
          total: 0,
          lastPage: 1,
        ),
        error: e.message,
        errorCode: 'NETWORK_ERROR',
      );
    } catch (e) {
      return FollowerListResponse(
        success: false,
        message: 'An unexpected error occurred',
        status: 500,
        data: [],
        meta: PaginationMeta(
          page: page,
          size: 0,
          totalElements: 0,
          totalPages: 0,
          hasNext: false,
          hasPrevious: false,
          perPage: perPage,
          total: 0,
          lastPage: 1,
        ),
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Fetch list of users that the current user is following
  Future<FollowerListResponse> getFollowing({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) {
        return FollowerListResponse(
          success: false,
          message: 'A valid Bearer token is required.',
          status: 401,
          data: [],
          meta: PaginationMeta(
            page: page,
            size: 0,
            totalElements: 0,
            totalPages: 0,
            hasNext: false,
            hasPrevious: false,
            perPage: perPage,
            total: 0,
            lastPage: 1,
          ),
          error: 'AUTH_TOKEN_MISSING',
          errorCode: 'AUTH_TOKEN_MISSING',
        );
      }

      final response = await _dio.get(
        '$_baseUrl/me/following',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      final followingResponse = FollowerListResponse.fromJson(
        response.data as Map<String, dynamic>,
      );

      return followingResponse;
    } on DioException catch (e) {
      return FollowerListResponse(
        success: false,
        message: e.message ?? 'Failed to fetch following',
        status: e.response?.statusCode ?? 500,
        data: [],
        meta: PaginationMeta(
          page: page,
          size: 0,
          totalElements: 0,
          totalPages: 0,
          hasNext: false,
          hasPrevious: false,
          perPage: perPage,
          total: 0,
          lastPage: 1,
        ),
        error: e.message,
        errorCode: 'NETWORK_ERROR',
      );
    } catch (e) {
      return FollowerListResponse(
        success: false,
        message: 'An unexpected error occurred',
        status: 500,
        data: [],
        meta: PaginationMeta(
          page: page,
          size: 0,
          totalElements: 0,
          totalPages: 0,
          hasNext: false,
          hasPrevious: false,
          perPage: perPage,
          total: 0,
          lastPage: 1,
        ),
        error: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// Fetch user profile by ID
  Future<ProfileResponse> getUserProfileById(String userId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) {
        return ProfileResponse(
          success: false,
          message: 'A valid Bearer token is required.',
          status: 401,
          error: 'AUTH_TOKEN_MISSING',
          errorCode: 'AUTH_TOKEN_MISSING',
        );
      }

      final response = await _dio.get(
        '$_baseUrl/$userId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
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
}
