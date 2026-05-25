// Community Model - matches API response
class Community {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String? coverImage;
  final String joinType; // 'open' or 'invite'
  final String status; // 'active', 'inactive'
  final String createdBy;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    this.coverImage,
    required this.joinType,
    required this.status,
    required this.createdBy,
    required this.memberCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      categoryId: json['category_id'] as String? ?? '',
      coverImage: json['cover_image'] as String?,
      joinType: json['join_type'] as String? ?? 'open',
      status: json['status'] as String? ?? 'active',
      createdBy: json['created_by'] as String? ?? '',
      memberCount: json['member_count'] as int? ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_id': categoryId,
      'cover_image': coverImage,
      'join_type': joinType,
      'status': status,
      'created_by': createdBy,
      'member_count': memberCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// Community Member Model
class CommunityMember {
  final String id;
  final String communityId;
  final String userId;
  final String role; // 'admin', 'moderator', 'member'
  final String status; // 'active', 'inactive'
  final DateTime joinedAt;

  CommunityMember({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      id: json['id'] as String? ?? '',
      communityId: json['community_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      status: json['status'] as String? ?? 'active',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community_id': communityId,
      'user_id': userId,
      'role': role,
      'status': status,
      'joined_at': joinedAt.toIso8601String(),
    };
  }
}

// Community Join Response
class CommunityJoinResponse {
  final String id;
  final String communityId;
  final String userId;
  final String role;
  final String status;
  final DateTime joinedAt;

  CommunityJoinResponse({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.role,
    required this.status,
    required this.joinedAt,
  });

  factory CommunityJoinResponse.fromJson(Map<String, dynamic> json) {
    return CommunityJoinResponse(
      id: json['id'] as String? ?? '',
      communityId: json['community_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      role: json['role'] as String? ?? 'member',
      status: json['status'] as String? ?? 'active',
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : DateTime.now(),
    );
  }
}

// Post Comment Model
class PostComment {
  final String id;
  final String postId;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.content,
    required this.likeCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'username': username,
      'user_avatar': userAvatar,
      'content': content,
      'like_count': likeCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
