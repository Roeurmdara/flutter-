import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import '../models/follower_model.dart';
import 'secure_storage_service.dart';
import 'dio_client.dart';

class UserProfileService {
  static const String _baseUrl = '/users';

  final DioClient _dioClient;
  final SecureStorageService _secureStorage;
  String? _authToken;

  UserProfileService({
    DioClient? dioClient,
    SecureStorageService? secureStorage,
  })  : _dioClient = dioClient ?? DioClient(),
        _secureStorage = secureStorage ?? SecureStorageService();

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

    final secureToken = await _secureStorage.getAccessToken();
    if (secureToken != null && secureToken.isNotEmpty) {
      _authToken = secureToken;
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

      final response = await _dioClient.get('$_baseUrl/me');

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

      final response = await _dioClient.put(
        '$_baseUrl/me',
        data: request.toJson(),
        // DioClient adds Authorization automatically
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

  /// Upload an avatar image through POST /media/upload.
  /// Returns the uploaded image URL on success, or null on failure.
  Future<String?> uploadAvatar(File file) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) return null;

      final fileName = file.path.split(Platform.pathSeparator).last;
      final form = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'context': 'avatar',
      });

      final response = await _dioClient.post(
        '/media/upload',
        data: form,
      );

      if (response.statusCode == null ||
          response.statusCode! < 200 ||
          response.statusCode! >= 300) {
        return null;
      }

      final body = response.data;
      if (body is Map && body['data'] is Map) {
        final data = body['data'] as Map;
        final url = data['url'];
        return url is String && url.trim().isNotEmpty ? url.trim() : null;
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

      final response = await _dioClient.get(
      '$_baseUrl/me/followers',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
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

      final response = await _dioClient.get(
      '$_baseUrl/me/following',
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
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

  /// Follow a user by ID
  Future<bool> followUser(String userId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) return false;

      final response = await _dioClient.post(
      '$_baseUrl/$userId/follow',
    );

      return response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Unfollow a user by ID
  Future<bool> unfollowUser(String userId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) return false;

      final response = await _dioClient.delete(
      '$_baseUrl/$userId/follow',
    );

      return response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  /// Fetch follow stats for a user by ID
  Future<Map<String, dynamic>?> getFollowStats(String userId) async {
    try {
      final authToken = await _getAuthToken();
      if (authToken == null || authToken.isEmpty) return null;

      final response = await _dioClient.get(
      '$_baseUrl/$userId/follow/stats',
    );

      if (response.data is Map && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>?;
      }
      return null;
    } catch (_) {
      return null;
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
      final response = await _dioClient.get('$_baseUrl/$userId');
      return ProfileResponse.fromJson(response.data as Map<String, dynamic>);
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
