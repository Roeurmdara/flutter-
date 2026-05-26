import 'package:dio/dio.dart';
import '../models/community_model.dart';

/// Service for handling community API operations
class CommunityService {
  static const String _baseUrl =
      'https://habit-api.rattanakmony.com/api/v1/communities';

  final Dio _dio;

  CommunityService({Dio? dio}) : _dio = dio ?? Dio();

  /// Get all communities with pagination
  /// [page] - Page number (default: 1)
  /// [perPage] - Items per page (default: 10)
  Future<CommunityListResponse> getCommunities({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        _baseUrl,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        final List<dynamic> communitiesData =
            data['data'] as List<dynamic>? ?? [];
        final communities = communitiesData
            .map((json) => Community.fromJson(json as Map<String, dynamic>))
            .toList();

        final metaData = data['meta'] as Map<String, dynamic>? ?? {};
        final pagination = PaginationMeta.fromJson(metaData);

        return CommunityListResponse(
          communities: communities,
          pagination: pagination,
        );
      } else {
        throw Exception(
          'Failed to fetch communities: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching communities: $e');
    }
  }

  /// Get a specific community by ID
  Future<Community> getCommunityById(String communityId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$communityId',
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final communityData = data['data'] as Map<String, dynamic>? ?? {};

        return Community.fromJson(communityData);
      } else {
        throw Exception(
          'Failed to fetch community: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching community: $e');
    }
  }

  /// Join a community
  Future<void> joinCommunity(String communityId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/$communityId/join',
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception(
          'Failed to join community: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error joining community: $e');
    }
  }

  /// Leave a community
  Future<bool> leaveCommunity(String communityId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/$communityId/leave',
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception(
          'Failed to leave community: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error leaving community: $e');
    }
  }

  /// Get members of a community with pagination
  /// [communityId] - The community ID
  /// [page] - Page number (default: 1)
  /// [perPage] - Items per page (default: 10)
  Future<CommunityMembersResponse> getCommunityMembers(
    String communityId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/$communityId/members',
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;

        final List<dynamic> membersData = data['data'] as List<dynamic>? ?? [];
        final members = membersData
            .map((json) =>
                CommunityMember.fromJson(json as Map<String, dynamic>))
            .toList();

        final metaData = data['meta'] as Map<String, dynamic>? ?? {};
        final pagination = PaginationMeta.fromJson(metaData);

        return CommunityMembersResponse(
          members: members,
          pagination: pagination,
        );
      } else {
        throw Exception(
          'Failed to fetch community members: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching community members: $e');
    }
  }

  /// Create a new community
  Future<Community> createCommunity({
    required String name,
    required String description,
    required String categoryId,
    String? coverImage,
    String joinType = 'open',
    String? customColor,
    String? customEmoji,
  }) async {
    try {
      final requestData = {
        'name': name,
        'description': description,
        'category_id': categoryId,
        'cover_image': coverImage ?? 'https://example.com/',
        'join_type': joinType,
        'status': 'active',
        if (customColor != null) 'custom_color': customColor,
        if (customEmoji != null) 'custom_emoji': customEmoji,
      };

      final response = await _dio.post(
        _baseUrl,
        data: requestData,
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final communityData = data['data'] as Map<String, dynamic>? ?? {};

        return Community.fromJson(communityData);
      } else {
        throw Exception(
          'Failed to create community: ${response.statusCode} - ${response.data}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error creating community: $e');
    }
  }
}

/// Response model for community list
class CommunityListResponse {
  final List<Community> communities;
  final PaginationMeta pagination;

  CommunityListResponse({
    required this.communities,
    required this.pagination,
  });
}

/// Response model for community members
class CommunityMembersResponse {
  final List<CommunityMember> members;
  final PaginationMeta pagination;

  CommunityMembersResponse({
    required this.members,
    required this.pagination,
  });
}

/// Community member model
class CommunityMember {
  final String userId;
  final String username;
  final String? avatar;
  final String role;

  CommunityMember({
    required this.userId,
    required this.username,
    this.avatar,
    required this.role,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String?,
      role: json['role'] as String? ?? 'member',
    );
  }
}

/// Pagination metadata
class PaginationMeta {
  final int page;
  final int size;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  PaginationMeta({
    required this.page,
    required this.size,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 10,
      total: json['total'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );
  }
}
