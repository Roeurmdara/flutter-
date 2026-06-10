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
  final String? email;
  final String? avatarUrl;
  final String? bio;

  UserProfile({
    required this.username,
    this.email,
    this.avatarUrl,
    this.bio,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = _objectValue(json['user']) ?? _objectValue(json['profile']);
    return UserProfile(
      username: _stringValue(json['username']) ??
          _stringValue(json['name']) ??
          _stringValue(json['display_name']) ??
          _stringValue(user?['username']) ??
          _stringValue(user?['name']) ??
          _stringValue(user?['display_name']) ??
          _stringValue(json['email']) ??
          '',
      email: _stringValue(json['email']) ?? _stringValue(user?['email']),
      avatarUrl: _stringValue(json['avatar_url']) ??
          _stringValue(json['avatar']) ??
          _stringValue(user?['avatar_url']) ??
          _stringValue(user?['avatar']),
      bio: _stringValue(json['bio']) ?? _stringValue(user?['bio']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'bio': bio,
    };
  }

  UserProfile copyWith({
    String? username,
    String? email,
    String? avatarUrl,
    String? bio,
  }) {
    return UserProfile(
      username: username ?? this.username,
      email: email ?? this.email,
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
    final data = _objectValue(json['data']);
    final profileData =
        _objectValue(data?['profile']) ?? _objectValue(data?['user']) ?? data;
    return ProfileResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      data: profileData != null ? UserProfile.fromJson(profileData) : null,
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

Map<String, dynamic>? _objectValue(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _stringValue(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}
