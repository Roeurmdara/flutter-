class CommunityPost {
  final String id;
  final String communityId;
  final String authorId;
  final String contentType;
  final String title;
  final String body;
  final bool isPinned;
  final String status;
  final int likeCount;
  final int commentCount;
  final String? imageUrl;
  final String? authorUsername;
  final String? authorAvatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  CommunityPost({
    required this.id,
    required this.communityId,
    required this.authorId,
    required this.contentType,
    required this.title,
    required this.body,
    required this.isPinned,
    required this.status,
    required this.likeCount,
    required this.commentCount,
    this.imageUrl,
    this.authorUsername,
    this.authorAvatarUrl,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now();
    final updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'].toString())
        : createdAt;
    final authorJson = json['author'] is Map
        ? Map<String, dynamic>.from(json['author'] as Map)
        : null;

    return CommunityPost(
      id: json['id']?.toString() ?? '',
      communityId: json['community_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      contentType: json['content_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      isPinned: json['is_pinned'] as bool? ?? false,
      status: json['status']?.toString() ?? '',
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url']?.toString(),
      authorUsername: authorJson?['username']?.toString(),
      authorAvatarUrl: authorJson?['avatar_url']?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'community_id': communityId,
        'author_id': authorId,
        'content_type': contentType,
        'title': title,
        'body': body,
        'is_pinned': isPinned,
        'status': status,
        'like_count': likeCount,
        'comment_count': commentCount,
        'image_url': imageUrl,
        'author': {
          if (authorUsername != null) 'username': authorUsername,
          if (authorAvatarUrl != null) 'avatar_url': authorAvatarUrl,
        },
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
      };
}

class CommunityPostComment {
  final String id;
  final String postId;
  final String authorId;
  final String body;
  final String status;
  final int likeCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? authorUsername;
  final String? authorAvatarUrl;

  CommunityPostComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.body,
    required this.status,
    required this.likeCount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.authorUsername,
    this.authorAvatarUrl,
  });

  factory CommunityPostComment.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at'] != null
        ? DateTime.parse(json['created_at'].toString())
        : DateTime.now();
    final updatedAt = json['updated_at'] != null
        ? DateTime.parse(json['updated_at'].toString())
        : createdAt;
    final authorJson = json['author'] is Map
        ? Map<String, dynamic>.from(json['author'] as Map)
        : null;

    return CommunityPostComment(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      authorId: json['author_id']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'].toString())
          : null,
      authorUsername: authorJson?['username']?.toString(),
      authorAvatarUrl: authorJson?['avatar_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'post_id': postId,
        'author_id': authorId,
        'body': body,
        'status': status,
        'like_count': likeCount,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'deleted_at': deletedAt?.toIso8601String(),
        'author': {
          if (authorUsername != null) 'username': authorUsername,
          if (authorAvatarUrl != null) 'avatar_url': authorAvatarUrl,
        },
      };
}

class PostReaction {
  final String type; // "like"
  final String userId;

  PostReaction({
    required this.type,
    required this.userId,
  });

  factory PostReaction.fromJson(Map<String, dynamic> json) {
    return PostReaction(
      type: json['type'] as String,
      userId: json['user_id'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'user_id': userId,
      };
}

class PostListResponse {
  final List<CommunityPost> data;
  final PaginationMeta meta;

  PostListResponse({
    required this.data,
    required this.meta,
  });

  factory PostListResponse.fromJson(Map<String, dynamic> json) {
    return PostListResponse(
      data: (json['data'] as List<dynamic>)
          .map((post) => CommunityPost.fromJson(post as Map<String, dynamic>))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }
}

class CommentsListResponse {
  final List<CommunityPostComment> data;
  final PaginationMeta meta;

  CommentsListResponse({
    required this.data,
    required this.meta,
  });

  factory CommentsListResponse.fromJson(dynamic json) {
    // Handle both direct list responses and wrapped responses
    List<dynamic> commentsList = [];
    Map<String, dynamic>? metaData;

    if (json['data'] is List) {
      commentsList = json['data'] as List<dynamic>;
      metaData = json['meta'] as Map<String, dynamic>?;
    } else if (json is List) {
      commentsList = json;
    }

    return CommentsListResponse(
      data: commentsList
          .map((comment) =>
              CommunityPostComment.fromJson(comment as Map<String, dynamic>))
          .toList(),
      meta: metaData != null
          ? PaginationMeta.fromJson(metaData)
          : PaginationMeta(
              page: 1,
              size: commentsList.length,
              totalElements: commentsList.length,
              totalPages: 1,
              hasNext: false,
              hasPrevious: false,
              perPage: commentsList.length,
              total: commentsList.length,
              lastPage: 1,
            ),
    );
  }
}

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
      page: (json['page'] as num?)?.toInt() ?? 1,
      size: (json['size'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ??
          (json['total'] as num?)?.toInt() ??
          0,
      totalPages: (json['totalPages'] as num?)?.toInt() ??
          ((json['last_page'] as num?)?.toInt() ?? 1),
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
      perPage: (json['per_page'] as num?)?.toInt() ??
          (json['size'] as num?)?.toInt() ??
          10,
      total: (json['total'] as num?)?.toInt() ?? 0,
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
    );
  }
}
