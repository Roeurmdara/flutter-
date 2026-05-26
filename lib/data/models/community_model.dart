// Community Model - matches API response
class Community {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String? coverImage;
  final String joinType;
  final String status;
  final String createdBy;
  final int memberCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? customColor; // hex string e.g. "FF7C3AED"
  final String? customEmoji;

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
    this.customColor,
    this.customEmoji,
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
      customColor: json['custom_color'] as String?,
      customEmoji: json['custom_emoji'] as String?,
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
      if (customColor != null) 'custom_color': customColor,
      if (customEmoji != null) 'custom_emoji': customEmoji,
    };
  }
}