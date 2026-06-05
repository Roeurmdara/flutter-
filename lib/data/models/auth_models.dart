// Registration Request Model
class RegisterRequest {
  final String email;
  final String username;
  final String password;

  RegisterRequest({
    required this.email,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'username': username,
        'password': password,
      };
}

// Login Request Model
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
      };
}

// Password Reset Request Model
class PasswordResetRequest {
  final String email;
  final String redirectUri;

  PasswordResetRequest({
    required this.email,
    required this.redirectUri,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'redirect_uri': 'http://habit-api.rattanakmony.com/*',
      };
}

// Auth Response Model
class AuthResponse {
  final bool success;
  final String message;
  final int status;
  final AuthData? data;
  final String? error;
  final String? errorCode;

  AuthResponse({
    required this.success,
    required this.message,
    required this.status,
    this.data,
    this.error,
    this.errorCode,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      data: json['data'] != null
          ? AuthData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      error: json['error'] != null
          ? (json['error'] is String
              ? json['error']
              : (json['error'] as Map<String, dynamic>)['message'])
          : null,
      errorCode: json['error'] != null && json['error'] is Map
          ? (json['error'] as Map<String, dynamic>)['code']
          : null,
    );
  }
}

// Auth Data Model (contains user info and token)
class AuthData {
  final UserAuthInfo? user;
  final String? token;
  final String? refreshToken;
  final String? message;

  AuthData({
    this.user,
    this.token,
    this.refreshToken,
    this.message,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    final tokensMap = json['tokens'] as Map<String, dynamic>?;
    final token = tokensMap?['access_token'] as String? ??
        json['access_token'] as String? ??
        json['token'] as String?;
    final refreshToken = tokensMap?['refresh_token'] as String? ??
        json['refresh_token'] as String?;

    final userJson = json['user'] as Map<String, dynamic>?;

    return AuthData(
      user: userJson != null ? UserAuthInfo.fromJson(userJson) : null,
      token: token,
      refreshToken: refreshToken,
      message: json['message'] as String?,
    );
  }
}

// User Info from Auth Response
class UserAuthInfo {
  final String id;
  final String email;
  final String? role;
  final String? status;
  final String username;
  final String? avatarUrl;
  final String? bio;
  final String? verifiedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? lastActiveAt;
  final bool? isVerified;
  final bool? isDeleted;
  final String? keycloakSubject;
  final String? token;

  UserAuthInfo({
    required this.id,
    required this.email,
    this.role,
    this.status,
    required this.username,
    this.avatarUrl,
    this.bio,
    this.verifiedAt,
    this.createdAt,
    this.updatedAt,
    this.lastActiveAt,
    this.isVerified,
    this.isDeleted,
    this.keycloakSubject,
    this.token,
  });

  factory UserAuthInfo.fromJson(Map<String, dynamic> json) {
    return UserAuthInfo(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
      status: json['status'] as String?,
      username: json['username'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      verifiedAt: json['verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      lastActiveAt: json['last_active_at'] as String?,
      isVerified: json['is_verified'] as bool?,
      isDeleted: json['is_deleted'] as bool?,
      keycloakSubject: json['keycloak_subject'] as String?,
      token: json['token'] as String? ?? json['access_token'] as String?,
    );
  }
}
