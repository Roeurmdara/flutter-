import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit_category_model.dart';
import '../models/discover_template_model.dart';
import '../services/habit_category_service.dart';

// Service provider
final habitCategoryServiceProvider = Provider<HabitCategoryService>((ref) {
  return HabitCategoryService();
});

// Categories provider
final categoriesProvider = FutureProvider<List<HabitCategory>>((ref) async {
  final service = ref.watch(habitCategoryServiceProvider);
  return service.getCategories();
});

// Templates provider for a specific category
final categoryTemplatesProvider =
    FutureProvider.family<List<DiscoverTemplate>, String>(
        (ref, categoryId) async {
  final service = ref.watch(habitCategoryServiceProvider);
  return service.getCategoryTemplates(categoryId);
});
