// Discover Template Model - for templates in discover page
class DiscoverTemplate {
  final String id;
  final String categoryId;
  final String title;
  final String description;
  final String suggestedFrequency;
  final String targetValue;
  final String targetUnit;
  final int durationDays;
  final String tips;
  final bool isPublished;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiscoverTemplate({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.suggestedFrequency,
    required this.targetValue,
    required this.targetUnit,
    required this.durationDays,
    required this.tips,
    required this.isPublished,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiscoverTemplate.fromJson(Map<String, dynamic> json) {
    return DiscoverTemplate(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      suggestedFrequency: json['suggested_frequency'] as String? ?? 'daily',
      targetValue: json['target_value'] as String? ?? '0',
      targetUnit: json['target_unit'] as String? ?? '',
      durationDays: json['duration_days'] as int? ?? 1,
      tips: json['tips'] as String? ?? '',
      isPublished: json['is_published'] as bool? ?? false,
      createdBy: json['created_by'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'category_id': categoryId,
        'title': title,
        'description': description,
        'suggested_frequency': suggestedFrequency,
        'target_value': targetValue,
        'target_unit': targetUnit,
        'duration_days': durationDays,
        'tips': tips,
        'is_published': isPublished,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
