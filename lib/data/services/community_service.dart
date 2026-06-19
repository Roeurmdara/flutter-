import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/community_model.dart';
import '../../core/exceptions/api_exception.dart';

/// Service for handling community API operations
class CommunityService {
  static const String _basePath = '/communities';

  final Dio _dio;

  CommunityService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: AppConstants.baseUrl));

  /// Get all communities with pagination
  /// [page] - Page number (default: 1)
  /// [perPage] - Items per page (default: 10)
  Future<CommunityListResponse> getCommunities({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        _basePath,
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

      if (_isSuccess(response)) {
        final data = _responseMap(response);
        final communities = _extractList(
          data,
          keys: const ['communities', 'items', 'results', 'records', 'data'],
        ).map(Community.fromJson).toList();
        final pagination = PaginationMeta.fromJson(_extractMeta(data));

        return CommunityListResponse(
          communities: communities,
          pagination: pagination,
        );
      } else {
        throw ApiException(response.statusCode, response.data);
      }
    } on ApiException {
      rethrow;
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
        '$_basePath/$communityId',
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (_isSuccess(response)) {
        final data = _responseMap(response);
        final communityData = _objectValue(data['data']) ?? data;

        return Community.fromJson(communityData);
      } else {
        throw ApiException(response.statusCode, response.data);
      }
    } on ApiException {
      rethrow;
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
        '$_basePath/$communityId/join',
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (_isSuccess(response)) {
        return;
      } else {
        throw ApiException(response.statusCode, response.data);
      }
    } on ApiException {
      rethrow;
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
        '$_basePath/$communityId/leave',
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (_isSuccess(response)) {
        return true;
      } else if (response.statusCode == 404 &&
          response.data is Map<String, dynamic> &&
          ((response.data as Map<String, dynamic>)['error']
                  as Map<String, dynamic>?)?['code'] ==
              'COMMUNITY_MEMBER_NOT_FOUND') {
        return true;
      } else {
        throw ApiException(response.statusCode, response.data);
      }
    } on ApiException {
      rethrow;
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
        '$_basePath/$communityId/members',
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

      if (_isSuccess(response)) {
        final data = _responseMap(response);
        final members = _extractList(
          data,
          keys: const ['members', 'items', 'results', 'records', 'data'],
        ).map(CommunityMember.fromJson).toList();
        final pagination = PaginationMeta.fromJson(_extractMeta(data));

        return CommunityMembersResponse(
          members: members,
          pagination: pagination,
        );
      } else {
        throw ApiException(response.statusCode, response.data);
      }
    } on ApiException {
      rethrow;
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
        if (coverImage != null && coverImage.trim().isNotEmpty)
          'cover_image': coverImage.trim(),
        'join_type': joinType,
        'status': 'active',
      };

      final response = await _dio.post(
        _basePath,
        data: requestData,
        options: Options(
          contentType: Headers.jsonContentType,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (_isSuccess(response)) {
        final data = _responseMap(response);
        final communityData = _objectValue(data['data']) ?? data;

        return Community.fromJson(communityData);
      } else {
        throw ApiException(response.statusCode, response.data);
      }
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Error creating community: $e');
    }
  }

  bool _isSuccess(Response response) =>
      response.statusCode != null &&
      response.statusCode! >= 200 &&
      response.statusCode! < 300;

  Map<String, dynamic> _responseMap(Response response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    throw FormatException('Expected JSON object, got ${data.runtimeType}');
  }

  Map<String, dynamic>? _objectValue(Object? value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<Map<String, dynamic>> _extractList(
    Map<String, dynamic> responseData, {
    required List<String> keys,
  }) {
    final list = _findList(responseData['data'], keys) ??
        _findList(responseData, keys) ??
        const <Object?>[];

    return list.map(_objectValue).whereType<Map<String, dynamic>>().toList();
  }

  List<Object?>? _findList(Object? value, List<String> keys) {
    if (value is List) return value;
    final map = _objectValue(value);
    if (map == null) return null;

    for (final key in keys) {
      final nested = map[key];
      if (nested is List) return nested;
    }

    for (final key in const ['data', 'items', 'results', 'records']) {
      final nested = map[key];
      if (nested is List) return nested;
    }

    final mappedObjects = map.values.whereType<Map>().toList();
    if (mappedObjects.isNotEmpty && mappedObjects.length == map.length) {
      return mappedObjects;
    }

    return null;
  }

  Map<String, dynamic> _extractMeta(Map<String, dynamic> responseData) {
    final topLevelMeta = _objectValue(responseData['meta']);
    if (topLevelMeta != null) return topLevelMeta;

    final data = _objectValue(responseData['data']);
    if (data == null) return const {};

    final nestedMeta =
        _objectValue(data['meta']) ?? _objectValue(data['links']);
    if (nestedMeta != null) return nestedMeta;

    const metaKeys = {
      'page',
      'size',
      'totalElements',
      'totalPages',
      'hasNext',
      'hasPrevious',
      'per_page',
      'total',
      'last_page',
    };
    if (data.keys.any(metaKeys.contains)) return data;

    return const {};
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
  final String id;
  final String communityId;
  final String userId;
  final String username;
  final String? avatar;
  final String role;
  final String status;
  final DateTime? joinedAt;

  CommunityMember({
    this.id = '',
    this.communityId = '',
    required this.userId,
    required this.username,
    this.avatar,
    required this.role,
    this.status = 'active',
    this.joinedAt,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    final user = _objectValue(json['user']) ??
        _objectValue(json['profile']) ??
        _objectValue(json['member']) ??
        _objectValue(json['account']);

    return CommunityMember(
      id: _stringValue(json['id']) ?? '',
      communityId: _stringValue(json['community_id']) ?? '',
      userId: _stringValue(json['user_id']) ??
          _stringValue(json['member_user_id']) ??
          _stringValue(json['profile_id']) ??
          _stringValue(user?['id']) ??
          _stringValue(user?['user_id']) ??
          _stringValue(json['id']) ??
          '',
      username: _stringValue(json['username']) ??
          _stringValue(json['name']) ??
          _stringValue(json['display_name']) ??
          _stringValue(user?['username']) ??
          _stringValue(user?['name']) ??
          _stringValue(user?['display_name']) ??
          _stringValue(user?['email']) ??
          '',
      avatar: _stringValue(json['avatar']) ??
          _stringValue(json['avatar_url']) ??
          _stringValue(json['profile_photo_url']) ??
          _stringValue(user?['avatar']) ??
          _stringValue(user?['avatar_url']) ??
          _stringValue(user?['profile_photo_url']),
      role: _stringValue(json['role']) ?? 'member',
      status: _stringValue(json['status']) ?? 'active',
      joinedAt: _dateValue(json['joined_at']),
    );
  }
}

/// Pagination metadata
class PaginationMeta {
  final int page;
  final int size;
  final int totalElements;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final int perPage;
  final int lastPage;

  PaginationMeta({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.perPage,
    required this.lastPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    final page =
        _intValue(json['page']) ?? _intValue(json['current_page']) ?? 1;
    final size = _intValue(json['size']) ?? _intValue(json['per_page']) ?? 10;
    final totalElements =
        _intValue(json['totalElements']) ?? _intValue(json['total']) ?? 0;
    final totalPages = _intValue(json['totalPages']) ??
        _intValue(json['last_page']) ??
        _intValue(json['lastPage']) ??
        0;

    return PaginationMeta(
      page: page,
      size: size,
      totalElements: totalElements,
      total: _intValue(json['total']) ?? totalElements,
      totalPages: totalPages,
      hasNext: _boolValue(json['hasNext']) ?? page < totalPages,
      hasPrevious: _boolValue(json['hasPrevious']) ?? page > 1,
      perPage: _intValue(json['per_page']) ?? size,
      lastPage: _intValue(json['last_page']) ?? totalPages,
    );
  }
}

String? _stringValue(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

Map<String, dynamic>? _objectValue(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

int? _intValue(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

bool? _boolValue(Object? value) {
  if (value is bool) return value;
  final text = value?.toString().toLowerCase().trim();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

DateTime? _dateValue(Object? value) {
  final text = _stringValue(value);
  return text == null ? null : DateTime.tryParse(text);
}
