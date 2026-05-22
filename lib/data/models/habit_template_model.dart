// Habit Template Model
class HabitTemplate {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final String color;
  final String difficulty; // easy, medium, hard
  final String recommendedFrequency;
  final int recommendedDuration;
  final String tips;
  final int usageCount;
  final List<String> tags;

  HabitTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.recommendedFrequency,
    required this.recommendedDuration,
    required this.tips,
    required this.usageCount,
    required this.tags,
  });

  factory HabitTemplate.fromJson(Map<String, dynamic> json) {
    return HabitTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      difficulty: json['difficulty'] as String,
      recommendedFrequency: json['recommended_frequency'] as String,
      recommendedDuration: json['recommended_duration'] as int,
      tips: json['tips'] as String,
      usageCount: json['usage_count'] as int? ?? 0,
      tags: List<String>.from(json['tags'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'color': color,
      'difficulty': difficulty,
      'recommended_frequency': recommendedFrequency,
      'recommended_duration': recommendedDuration,
      'tips': tips,
      'usage_count': usageCount,
      'tags': tags,
    };
  }
}
