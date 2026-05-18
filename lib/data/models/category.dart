// lib/data/models/category.dart

class MealCategory {
  final String id;
  final String name;
  final String? thumbnail;
  final String? description;

  const MealCategory({
    required this.id,
    required this.name,
    this.thumbnail,
    this.description,
  });

  factory MealCategory.fromJson(Map<String, dynamic> json) {
    return MealCategory(
      id: json['idCategory']?.toString() ??
          json['id']?.toString() ??
          json['name']?.toString() ??
          '',
      name: json['strCategory']?.toString() ??
          json['category']?.toString() ??
          json['name']?.toString() ??
          'Unknown',
      thumbnail: json['strCategoryThumb']?.toString() ??
          json['category_thumb']?.toString() ??
          json['thumbnail']?.toString(),
      description: json['strCategoryDescription']?.toString() ??
          json['category_description']?.toString() ??
          json['description']?.toString(),
    );
  }
}
