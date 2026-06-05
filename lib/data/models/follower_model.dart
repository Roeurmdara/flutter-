// Follower/Following User Model
class FollowerUser {
  final String id;
  final String username;
  final String? avatar;
  final String? bio;

  FollowerUser({
    required this.id,
    required this.username,
    this.avatar,
    this.bio,
  });

  factory FollowerUser.fromJson(Map<String, dynamic> json) {
    return FollowerUser(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatar': avatar,
      'bio': bio,
    };
  }
}

// Pagination Metadata
class PaginationMeta {
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final int perPage;
  final int total;
  final int lastPage;

  PaginationMeta({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
      perPage: json['per_page'] as int? ?? 0,
      total: json['total'] as int? ?? 0,
      lastPage: json['last_page'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'size': size,
      'totalElements': totalElements,
      'totalPages': totalPages,
      'hasNext': hasNext,
      'hasPrevious': hasPrevious,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
    };
  }
}

// Follower List Response Model
class FollowerListResponse {
  final bool success;
  final String message;
  final int status;
  final List<FollowerUser> data;
  final PaginationMeta meta;
  final String? error;
  final String? errorCode;

  FollowerListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.data,
    required this.meta,
    this.error,
    this.errorCode,
  });

  factory FollowerListResponse.fromJson(Map<String, dynamic> json) {
    final metaJson = json['meta'] as Map<String, dynamic>? ?? {};
    final dataList = json['data'] as List? ?? [];

    return FollowerListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      data: dataList
          .map((item) => FollowerUser.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(metaJson),
      error: json['error'] != null
          ? (json['error'] is String
              ? json['error']
              : (json['error'] as Map)['message'] ?? json['error'].toString())
          : null,
      errorCode: json['error'] != null && json['error'] is Map
          ? (json['error'] as Map)['code'] as String?
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'status': status,
      'data': data.map((user) => user.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}
