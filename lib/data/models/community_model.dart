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
  final bool? isMember;
  final String? membershipStatus;
  final String? membershipRole;

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
    this.isMember,
    this.membershipStatus,
    this.membershipRole,
  });

  bool get isActive => status.toLowerCase() == 'active';

  factory Community.fromJson(Map<String, dynamic> json) {
    final coverImage = _validImageUrl(_stringValue(json['cover_image']));
    final membership = json['membership'] is Map<String, dynamic>
        ? json['membership'] as Map<String, dynamic>
        : null;

    return Community(
      id: _stringValue(json['id']) ?? '',
      name: _stringValue(json['name']) ?? '',
      description: _stringValue(json['description']) ?? '',
      categoryId: _stringValue(json['category_id']) ?? '',
      coverImage: coverImage,
      joinType: _stringValue(json['join_type']) ?? 'open',
      status: _stringValue(json['status']) ?? 'active',
      createdBy: _stringValue(json['created_by']) ?? '',
      memberCount: _intValue(json['member_count']) ?? 0,
      createdAt: _dateValue(json['created_at']) ?? DateTime.now(),
      updatedAt: _dateValue(json['updated_at']) ?? DateTime.now(),
      customColor: _stringValue(json['custom_color']),
      customEmoji: _stringValue(json['custom_emoji']),
      isMember: _boolValue(
        json['is_member'] ??
            json['is_joined'] ??
            json['joined'] ??
            json['isJoined'] ??
            membership?['is_member'],
      ),
      membershipStatus: _stringValue(
        json['membership_status'] ??
            json['member_status'] ??
            json['current_user_membership_status'] ??
            membership?['status'],
      ),
      membershipRole: _stringValue(
        json['membership_role'] ?? json['member_role'] ?? membership?['role'],
      ),
    );
  }

  static String? _validImageUrl(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) return null;
    if (uri.host == 'example.com' || uri.host.endsWith('.example.com')) {
      return null;
    }

    return trimmed;
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
      if (isMember != null) 'is_member': isMember,
      if (membershipStatus != null) 'membership_status': membershipStatus,
      if (membershipRole != null) 'membership_role': membershipRole,
    };
  }

  static String? _stringValue(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static int? _intValue(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '');
  }

  static bool? _boolValue(Object? value) {
    if (value is bool) return value;
    final text = value?.toString().toLowerCase().trim();
    if (text == 'true' || text == '1') return true;
    if (text == 'false' || text == '0') return false;
    return null;
  }

  static DateTime? _dateValue(Object? value) {
    final text = _stringValue(value);
    return text == null ? null : DateTime.tryParse(text);
  }
}
