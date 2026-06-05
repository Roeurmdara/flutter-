// Habit Template Model
class HabitTemplate {
  final String id;
  final String title;
  final String description;
  final String category; // category name
  final String categoryId; // category UUID
  final String icon; // emoji icon from category
  final String color; // hex color from category
  final String difficulty; // easy, medium, hard (derived from frequency)
  final String recommendedFrequency; // daily, 3x per week, etc.
  final int recommendedDuration; // duration in days or minutes
  final String tips;
  final int usageCount;
  final List<String> tags;
  final String targetValue; // e.g., "1.00"
  final String targetUnit; // e.g., "times"
  final int durationDays; // total duration in days

  HabitTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.categoryId,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.recommendedFrequency,
    required this.recommendedDuration,
    required this.tips,
    required this.usageCount,
    required this.tags,
    required this.targetValue,
    required this.targetUnit,
    required this.durationDays,
  });

  // Derive difficulty from frequency
  static String _deriveDifficulty(String frequency) {
    if (frequency.toLowerCase().contains('daily')) {
      return 'medium';
    } else if (frequency.toLowerCase().contains('weekly') ||
        frequency.toLowerCase().contains('week')) {
      return 'easy';
    } else {
      return 'hard';
    }
  }

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    final category = json['category'] as Map<String, dynamic>? ?? {};
    final categoryName = category['name'] as String? ?? 'Uncategorized';
    final icon = category['icon'] as String? ?? '📌';
    final colorHex = category['color_hex'] as String? ?? '#6366f1';
    final suggestedFrequency =
        json['suggested_frequency'] as String? ?? 'daily';
    final durationDays = json['duration_days'] as int? ?? 30;

    // Parse tags - handle various formats
    List<String> parsedTags = [];
    final tagsData = json['tags'];
    if (tagsData != null) {
      if (tagsData is List) {
        parsedTags = List<String>.from(tagsData.map((t) => t.toString()));
      } else if (tagsData is String) {
        // If tags is a string, try to split it
        parsedTags = tagsData
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      }
    }

    return HabitTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: categoryName,
      categoryId: json['category_id'] as String? ?? '',
      icon: icon,
      color: colorHex,
      difficulty: _deriveDifficulty(suggestedFrequency),
      recommendedFrequency: suggestedFrequency,
      recommendedDuration: durationDays,
      tips: json['tips'] as String? ?? '',
      usageCount: json['usage_count'] as int? ?? 0,
      tags: parsedTags,
      targetValue: json['target_value'] as String? ?? '1.00',
      targetUnit: json['target_unit'] as String? ?? 'times',
      durationDays: durationDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'category': category,
      'icon': icon,
      'color': color,
      'difficulty': difficulty,
      'suggested_frequency': recommendedFrequency,
      'duration_days': durationDays,
      'tips': tips,
      'usage_count': usageCount,
      'tags': tags,
      'target_value': targetValue,
      'target_unit': targetUnit,
    };
  }
}
