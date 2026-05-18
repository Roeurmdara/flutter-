// Habit Model
class Habit {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String icon;
  final String color;
  final String frequency; // daily, weekly, monthly
  final int duration; // in days
  final String? reminderTime;
  final String? notes;
  final DateTime createdAt;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final bool isArchived;
  final int currentStreak;
  final int bestStreak;
  final List<DateTime> completedDates;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.icon,
    required this.color,
    required this.frequency,
    required this.duration,
    this.reminderTime,
    this.notes,
    required this.createdAt,
    required this.startDate,
    this.endDate,
    required this.isActive,
    required this.isArchived,
    required this.currentStreak,
    required this.bestStreak,
    required this.completedDates,
  });

  // Calculate completion rate
  int get completionRate {
    if (completedDates.isEmpty) return 0;
    final daysDifference = DateTime.now().difference(startDate).inDays + 1;
    return ((completedDates.length / daysDifference) * 100).toInt();
  }

  // Check if completed today
  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any(
      (date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day,
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as int,
      reminderTime: json['reminder_time'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate:
          json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      isActive: json['is_active'] as bool? ?? true,
      isArchived: json['is_archived'] as bool? ?? false,
      currentStreak: json['current_streak'] as int? ?? 0,
      bestStreak: json['best_streak'] as int? ?? 0,
      completedDates: (json['completed_dates'] as List<dynamic>? ?? [])
          .map((date) => DateTime.parse(date as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'category': category,
      'icon': icon,
      'color': color,
      'frequency': frequency,
      'duration': duration,
      'reminder_time': reminderTime,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
      'is_archived': isArchived,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'completed_dates':
          completedDates.map((date) => date.toIso8601String()).toList(),
    };
  }

  Habit copyWith({
    String? id,
    String? userId,
    String? title,
    String? category,
    String? icon,
    String? color,
    String? frequency,
    int? duration,
    String? reminderTime,
    String? notes,
    DateTime? createdAt,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    bool? isArchived,
    int? currentStreak,
    int? bestStreak,
    List<DateTime>? completedDates,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
      reminderTime: reminderTime ?? this.reminderTime,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      isArchived: isArchived ?? this.isArchived,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      completedDates: completedDates ?? this.completedDates,
    );
  }
}
