class Habit {
  final String id;
  final String userId;
  final String? categoryId;
  final String title;
  final String description;
  final String status; // "created", "pending", etc.
  final String frequency; // frequency_type
  final String? category;
  final String? categoryIcon;
  final String? categoryColor;
  final DateTime startDate;
  final DateTime? endDate;
  final int currentStreak;
  final int bestStreak;
  final String todayStatus; // "pending", "completed"
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    required this.description,
    required this.status,
    required this.frequency,
    this.category,
    this.categoryIcon,
    this.categoryColor,
    required this.startDate,
    this.endDate,
    required this.currentStreak,
    required this.bestStreak,
    required this.todayStatus,
    required this.createdAt,
  });

  bool get isCompletedToday => todayStatus == 'completed';

  int get completionRate => 0; // calculate if needed

  factory Habit.fromJson(Map<String, dynamic> json) {
    final streak = json['streak'] as Map<String, dynamic>? ?? {};
    final categoryJson = json['category'] as Map<String, dynamic>?;

    return Habit(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: json['status'] as String? ?? 'created',
      frequency: json['frequency_type'] as String? ?? 'daily',
      category: categoryJson?['name'] as String?,
      categoryIcon: categoryJson?['icon'] as String?,
      categoryColor: categoryJson?['color_hex'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      currentStreak: streak['current'] as int? ?? 0,
      bestStreak: streak['longest'] as int? ?? 0,
      todayStatus: json['today_status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'status': status,
        'frequency_type': frequency,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };

  Habit copyWith({
    String? id,
    String? userId,
    String? categoryId,
    String? title,
    String? description,
    String? status,
    String? frequency,
    String? category,
    String? categoryIcon,
    String? categoryColor,
    DateTime? startDate,
    DateTime? endDate,
    int? currentStreak,
    int? bestStreak,
    String? todayStatus,
    DateTime? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      frequency: frequency ?? this.frequency,
      category: category ?? this.category,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      todayStatus: todayStatus ?? this.todayStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}