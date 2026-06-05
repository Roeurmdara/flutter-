class Activity {
  final String id;
  final String habitId;
  final String activityType;
  final String value;
  final String unit;
  final String? note;
  final DateTime settlementPeriodDate;
  final DateTime loggedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted; // Track completion status

  Activity({
    required this.id,
    required this.habitId,
    required this.activityType,
    required this.value,
    required this.unit,
    this.note,
    required this.settlementPeriodDate,
    required this.loggedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      activityType: json['activity_type'] as String? ?? '',
      value: json['value'] as String? ?? '0',
      unit: json['unit'] as String? ?? '',
      note: json['note'] as String?,
      settlementPeriodDate:
          DateTime.parse(json['settlement_period_date'] as String),
      loggedAt: DateTime.parse(json['logged_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'habit_id': habitId,
        'activity_type': activityType,
        'value': value,
        'unit': unit,
        'note': note,
        'settlement_period_date': settlementPeriodDate.toIso8601String(),
        'logged_at': loggedAt.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
        'is_completed': isCompleted,
      };

  Activity copyWith({
    String? id,
    String? habitId,
    String? activityType,
    String? value,
    String? unit,
    String? note,
    DateTime? settlementPeriodDate,
    DateTime? loggedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
  }) {
    return Activity(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      activityType: activityType ?? this.activityType,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      note: note ?? this.note,
      settlementPeriodDate: settlementPeriodDate ?? this.settlementPeriodDate,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class ActivityListResponse {
  final bool success;
  final String message;
  final int status;
  final List<Activity> data;
  final ActivityMeta meta;

  ActivityListResponse({
    required this.success,
    required this.message,
    required this.status,
    required this.data,
    required this.meta,
  });

  factory ActivityListResponse.fromJson(Map<String, dynamic> json) {
    return ActivityListResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      status: json['status'] as int? ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => Activity.fromJson(item as Map<String, dynamic>))
          .toList(),
      meta: ActivityMeta.fromJson(json['meta'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class ActivityMeta {
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  ActivityMeta({
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory ActivityMeta.fromJson(Map<String, dynamic> json) {
    return ActivityMeta(
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 0,
      totalElements: json['totalElements'] as int? ?? 0,
      totalPages:
          (json['totalPages'] as int?) ?? (json['last_page'] as int?) ?? 0,
      hasNext: json['hasNext'] as bool? ?? false,
      hasPrevious: json['hasPrevious'] as bool? ?? false,
    );
  }
}
