// Community Model
class Community {
  final String id;
  final String name;
  final String description;
  final String category;
  final String? avatar;
  final int memberCount;
  final int postCount;
  final DateTime createdAt;
  final bool isJoined;
  final List<String> tags;

  Community({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.avatar,
    required this.memberCount,
    required this.postCount,
    required this.createdAt,
    required this.isJoined,
    required this.tags,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    return Community(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      avatar: json['avatar'] as String?,
      memberCount: json['member_count'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      isJoined: json['is_joined'] as bool? ?? false,
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'avatar': avatar,
      'member_count': memberCount,
      'post_count': postCount,
      'created_at': createdAt.toIso8601String(),
      'is_joined': isJoined,
      'tags': tags,
    };
  }
}

// Community Post Model
class CommunityPost {
  final String id;
  final String communityId;
  final String userId;
  final String username;
  final String? userAvatar;
  final String content;
  final List<String> imageUrls;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final DateTime createdAt;
  final List<PostComment> comments;

  CommunityPost({
    required this.id,
    required this.communityId,
    required this.userId,
    required this.username,
    this.userAvatar,
    required this.content,
    required this.imageUrls,
    required this.likeCount,
    required this.commentCount,
    required this.isLiked,
    required this.createdAt,
    required this.comments,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] as String,
      communityId: json['community_id'] as String,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      userAvatar: json['user_avatar'] as String?,
      content: json['content'] as String,
      imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
      likeCount: json['like_count'] as int? ?? 0,
      commentCount: json['comment_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      comments: (json['comments'] as List? ?? [])
          .map((c) => PostComment.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'community_id': communityId,
      'user_id': userId,
      'username': username,
      'user_avatar': userAvatar,
      'content': content,
      'image_urls': imageUrls,
      'like_count': likeCount,
      'comment_count': commentCount,
      'is_liked': isLiked,
      'created_at': createdAt.toIso8601String(),
      'comments': comments.map((c) => c.toJson()).toList(),
    };
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
