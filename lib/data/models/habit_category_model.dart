// Habit Category Model - from API response
class HabitCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String colorHex;
  final bool isActive;
  final int sortOrder;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  HabitCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.colorHex,
    required this.isActive,
    required this.sortOrder,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitCategory.fromJson(Map<String, dynamic> json) {
    return HabitCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String? ?? 'string',
      colorHex: json['color_hex'] as String? ?? '#FF6B6B',
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
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
        'name': name,
        'description': description,
        'icon': icon,
        'color_hex': colorHex,
        'is_active': isActive,
        'sort_order': sortOrder,
        'created_by': createdBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
