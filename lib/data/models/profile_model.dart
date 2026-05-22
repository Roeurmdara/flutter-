// User Profile Update Request Model
class UserProfileUpdateRequest {
  final String username;
  final String? avatarUrl;
  final String? bio;

  UserProfileUpdateRequest({
    required this.username,
    this.avatarUrl,
    this.bio,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (bio != null) 'bio': bio,
    };
  }
}

// User Profile Response Model
class UserProfile {
  final String username;
  final String? avatarUrl;
  final String? bio;

  UserProfile({
    required this.username,
    this.avatarUrl,
    this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
    };
  }

  UserProfile copyWith({
    String? username,
    String? avatarUrl,
    String? bio,
  }) {
    return UserProfile(
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
    );
  }
}

// API Response Wrapper
class ProfileResponse {
  final bool success;
  final String message;
  final int status;
  final UserProfile? data;
  final String? error;
  final String? errorCode;

  ProfileResponse({
    required this.success,
    required this.message,
    required this.status,
    this.data,
    this.error,
    this.errorCode,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      data: json['data'] != null
          ? UserProfile.fromJson(json['data'] as Map<String, dynamic>)
          : null,
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
}
