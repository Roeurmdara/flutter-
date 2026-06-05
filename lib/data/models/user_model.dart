// User Model
class User {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final String? avatar;
  final String? bio;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool emailVerified;
  final int totalStreak;
  final int totalHabits;
  final int completedToday;
  final List<String> achievements;
  final Map<String, dynamic> preferences;
  final String? token;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    this.avatar,
    this.bio,
    required this.createdAt,
    this.lastLogin,
    required this.emailVerified,
    required this.totalStreak,
    required this.totalHabits,
    required this.completedToday,
    required this.achievements,
    required this.preferences,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      avatar: json['avatar'] as String?,
      bio: json['bio'] as String?,
      token: json['token'] as String?, 
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      emailVerified: json['email_verified'] as bool? ?? false,
      totalStreak: json['total_streak'] as int? ?? 0,
      totalHabits: json['total_habits'] as int? ?? 0,
      completedToday: json['completed_today'] as int? ?? 0,
      achievements: List<String>.from(json['achievements'] as List? ?? []),
      preferences: Map<String, dynamic>.from(json['preferences'] as Map? ?? {}),
  
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'avatar': avatar,
      'bio': bio,
      'created_at': createdAt.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'email_verified': emailVerified,
      'total_streak': totalStreak,
      'total_habits': totalHabits,
      'completed_today': completedToday,
      'achievements': achievements,
      'preferences': preferences,
      'token': token,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? avatar,
    String? bio,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? emailVerified,
    int? totalStreak,
    int? totalHabits,
    int? completedToday,
    List<String>? achievements,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      emailVerified: emailVerified ?? this.emailVerified,
      totalStreak: totalStreak ?? this.totalStreak,
      totalHabits: totalHabits ?? this.totalHabits,
      completedToday: completedToday ?? this.completedToday,
      achievements: achievements ?? this.achievements,
      preferences: preferences ?? this.preferences,
      token: token ?? token,
    );
  }
}
