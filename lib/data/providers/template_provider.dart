import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart'; // Added for firstWhereOrNull
import 'package:flutter/foundation.dart';
import '../models/habit_template_model.dart';
import '../services/template_service.dart';
import '../services/dio_client.dart';

// ─── Template Service Provider ───────────────────────────────────────────

final templateServiceProvider = Provider((ref) {
  final dioClient = DioClient();
  return TemplateService(dioClient.dio);
});

// ─── Sample Template Data (Fallback) ─────────────────────────────────────

final _sampleTemplates = [
  HabitTemplate(
    id: 'tpl_001',
    title: 'Morning Run',
    description: 'Start your day with a refreshing morning run to boost energy',
    category: 'fitness',
    categoryId: 'cat_fitness',
    icon: '🏃',
    color: '#FF6B6B',
    difficulty: 'medium',
    recommendedFrequency: 'daily',
    recommendedDuration: 30,
    tips:
        'Start with 20 minutes and gradually increase. Wear comfortable shoes.',
    usageCount: 234,
    tags: ['cardio', 'morning', 'outdoor'],
    targetValue: '1.00',
    targetUnit: 'times',
    durationDays: 30,
  ),
  HabitTemplate(
    id: 'tpl_002',
    title: 'Meditation',
    description: 'Practice mindfulness and calm your mind',
    category: 'mindfulness',
    categoryId: 'cat_mindfulness',
    icon: '🧘',
    color: '#8B5CF6',
    difficulty: 'easy',
    recommendedFrequency: 'daily',
    recommendedDuration: 10,
    tips: 'Find a quiet place. Use guided meditations if needed.',
    usageCount: 456,
    tags: ['mindfulness', 'relaxation', 'mental-health'],
    targetValue: '1.00',
    targetUnit: 'times',
    durationDays: 30,
  ),
  HabitTemplate(
    id: 'tpl_003',
    title: 'Read 30 Minutes',
    description: 'Develop a reading habit and expand your knowledge',
    category: 'learning',
    categoryId: 'cat_learning',
    icon: '📚',
    color: '#3B82F6',
    difficulty: 'easy',
    recommendedFrequency: 'daily',
    recommendedDuration: 30,
    tips: 'Choose books that interest you. Set a consistent reading time.',
    usageCount: 189,
    tags: ['learning', 'knowledge', 'relaxation'],
    targetValue: '30',
    targetUnit: 'minutes',
    durationDays: 30,
  ),
  HabitTemplate(
    id: 'tpl_004',
    title: 'Drink Water',
    description: 'Stay hydrated throughout the day',
    category: 'health',
    categoryId: 'cat_health',
    icon: '💧',
    color: '#06B6D4',
    difficulty: 'easy',
    recommendedFrequency: 'daily',
    recommendedDuration: 1,
    tips: 'Aim for 8 glasses per day. Drink water with every meal.',
    usageCount: 567,
    tags: ['health', 'hydration', 'wellness'],
    targetValue: '8',
    targetUnit: 'glasses',
    durationDays: 30,
  ),
  HabitTemplate(
    id: 'tpl_005',
    title: 'Workout',
    description: 'Complete a full-body workout session',
    category: 'fitness',
    categoryId: 'cat_fitness',
    icon: '💪',
    color: '#EC4899',
    difficulty: 'hard',
    recommendedFrequency: '3x per week',
    recommendedDuration: 60,
    tips: 'Include warm-up and cool-down. Mix cardio and strength training.',
    usageCount: 312,
    tags: ['strength', 'fitness', 'health'],
    targetValue: '3',
    targetUnit: 'times',
    durationDays: 30,
  ),
  HabitTemplate(
    id: 'tpl_006',
    title: 'Study Coding',
    description: 'Dedicate time to learn programming',
    category: 'learning',
    categoryId: 'cat_learning',
    icon: '💻',
    color: '#10B981',
    difficulty: 'hard',
    recommendedFrequency: 'daily',
    recommendedDuration: 45,
    tips: 'Practice coding daily. Build small projects.',
    usageCount: 145,
    tags: ['coding', 'learning', 'technology'],
    targetValue: '1',
    targetUnit: 'hour',
    durationDays: 30,
  ),
  HabitTemplate(
    id: 'tpl_007',
    title: 'Journal Writing',
    description: 'Reflect on your day and track your thoughts',
    category: 'mindfulness',
    categoryId: 'cat_mindfulness',
    icon: '📝',
    color: '#FBBf24',
    difficulty: 'easy',
    recommendedFrequency: 'daily',
    recommendedDuration: 15,
    tips: 'Write freely without judgement. Make it a bedtime routine.',
    usageCount: 234,
    tags: ['reflection', 'mindfulness', 'growth'],
    targetValue: '1',
    targetUnit: 'page',
    durationDays: 30,
  ),
  HabitTemplate(
    id: 'tpl_008',
    title: 'Healthy Breakfast',
    description: 'Start your day with a nutritious breakfast',
    category: 'health',
    categoryId: 'cat_health',
    icon: '🥗',
    color: '#10B981',
    difficulty: 'easy',
    recommendedFrequency: 'daily',
    recommendedDuration: 20,
    tips: 'Include protein, fiber, and whole grains.',
    usageCount: 298,
    tags: ['nutrition', 'health', 'wellness'],
    targetValue: '1',
    targetUnit: 'meal',
    durationDays: 30,
  ),
];

// Helper function to get default templates
List<HabitTemplate> _getDefaultTemplates() => _sampleTemplates;

// ─── Template State ───────────────────────────────────────────────────────

class TemplateState {
  final List<HabitTemplate> templates;
  final bool isLoading;
  final String? error;
  final String? selectedTemplateId;
  final String filterCategory;

  TemplateState({
    this.templates = const [],
    this.isLoading = false,
    this.error,
    this.selectedTemplateId,
    this.filterCategory = 'all',
  });

  TemplateState copyWith({
    List<HabitTemplate>? templates,
    bool? isLoading,
    String? error,
    String? selectedTemplateId,
    String? filterCategory,
  }) {
    return TemplateState(
      templates: templates ?? this.templates,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedTemplateId: selectedTemplateId ?? this.selectedTemplateId,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }

  List<HabitTemplate> get filteredTemplates {
    if (filterCategory == 'all') return templates;
    return templates
        .where((t) => t.category.toLowerCase() == filterCategory.toLowerCase())
        .toList();
  }

  // FIXED: Using firstWhereOrNull explicitly removes layout compilation breaks
  HabitTemplate? get selectedTemplate {
    if (selectedTemplateId == null) return null;
    return templates.firstWhereOrNull((t) => t.id == selectedTemplateId);
  }
}

// ─── Template Notifier ────────────────────────────────────────────────────

class TemplateNotifier extends StateNotifier<TemplateState> {
  final TemplateService _service;

  TemplateNotifier(this._service) : super(TemplateState()) {
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final templates = await _service.fetchTemplates();
      if (templates.isEmpty) {
        state = state.copyWith(templates: _sampleTemplates, isLoading: false);
      } else {
        state = state.copyWith(templates: templates, isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        templates: _sampleTemplates,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadTemplatesByCategory(String category) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      if (category == 'all') {
        // Fetch all templates
        final templates = await _service.fetchTemplates();
        if (templates.isEmpty) {
          state = state.copyWith(templates: _sampleTemplates, isLoading: false);
        } else {
          state = state.copyWith(templates: templates, isLoading: false);
        }
      } else {
        // Fetch templates by category with pagination
        final response = await _service.fetchTemplatesByCategory(category);
        if (response.templates.isEmpty) {
          final filtered = _sampleTemplates
              .where((t) => t.category.toLowerCase() == category.toLowerCase())
              .toList();
          state = state.copyWith(templates: filtered, isLoading: false);
        } else {
          state =
              state.copyWith(templates: response.templates, isLoading: false);
        }
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setCategory(String category) {
    state = state.copyWith(filterCategory: category);
  }

  void selectTemplate(String templateId) {
    state = state.copyWith(selectedTemplateId: templateId);
  }

  void clearSelection() {
    state = state.copyWith(selectedTemplateId: null);
  }

  Future<void> updateTemplate(HabitTemplate updated) async {
    try {
      final result = await _service.updateTemplate(updated);
      if (result != null) {
        final index = state.templates.indexWhere((t) => t.id == updated.id);
        if (index >= 0) {
          final updatedList = [...state.templates];
          updatedList[index] = result;
          state = state.copyWith(templates: updatedList);
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> createTemplate(HabitTemplate template) async {
    try {
      final result = await _service.createTemplate(template);
      if (result != null) {
        state = state.copyWith(templates: [...state.templates, result]);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> deleteTemplate(String templateId) async {
    try {
      final success = await _service.deleteTemplate(templateId);
      if (success) {
        state = state.copyWith(
          templates: state.templates.where((t) => t.id != templateId).toList(),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> incrementUsageCount(String templateId) async {
    try {
      await _service.incrementTemplateUsage(templateId);
      final template = state.templates.firstWhere((t) => t.id == templateId);

      // Note: If your HabitTemplate model has a custom copyWith constructor,
      // you can replace this instantiation with: template.copyWith(usageCount: template.usageCount + 1)
      final updated = HabitTemplate(
        id: template.id,
        title: template.title,
        description: template.description,
        category: template.category,
        categoryId: template.categoryId,
        icon: template.icon,
        color: template.color,
        difficulty: template.difficulty,
        recommendedFrequency: template.recommendedFrequency,
        recommendedDuration: template.recommendedDuration,
        tips: template.tips,
        usageCount: template.usageCount + 1,
        tags: template.tags,
        targetValue: template.targetValue,
        targetUnit: template.targetUnit,
        durationDays: template.durationDays,
      );
      await updateTemplate(updated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  List<HabitTemplate> searchTemplates(String query) {
    if (query.isEmpty) return state.filteredTemplates;
    return state.filteredTemplates
        .where((t) =>
            t.title.toLowerCase().contains(query.toLowerCase()) ||
            t.description.toLowerCase().contains(query.toLowerCase()) ||
            t.tags
                .any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
        .toList();
  }
}

// ─── Providers ────────────────────────────────────────────────────────────

final templateProvider =
    StateNotifierProvider<TemplateNotifier, TemplateState>((ref) {
  final service = ref.watch(templateServiceProvider);
  return TemplateNotifier(service);
});

final allTemplatesProvider = Provider((ref) {
  return ref.watch(templateProvider).templates;
});

final templatesByCategoryProvider =
    FutureProvider.family<List<HabitTemplate>, String>((ref, categoryId) async {
  // Fetch templates by category from API with pagination
  final service = ref.read(templateServiceProvider);

  // Filter by category ID
  if (categoryId == 'all' || categoryId.isEmpty) {
    // Fetch all templates if 'all' category
    final allTemplates = await service.fetchTemplates();
    return allTemplates.isNotEmpty ? allTemplates : _getDefaultTemplates();
  }

  // Fetch templates for specific category using pagination
  try {
    final response = await service.fetchTemplatesByCategory(
      categoryId,
      page: 1,
      perPage: 50, // Get more templates per page for discovery
    );

    if (response.templates.isNotEmpty) {
      return response.templates;
    }
  } catch (e) {
    debugPrint('Error fetching templates by category: $e');
  }

  // Fallback to sample templates if API fails
  return _sampleTemplates
      .where((t) => t.categoryId.toLowerCase() == categoryId.toLowerCase())
      .toList();
});

final filteredTemplatesProvider = Provider((ref) {
  return ref.watch(templateProvider).filteredTemplates;
});

final selectedTemplateProvider = Provider((ref) {
  return ref.watch(templateProvider).selectedTemplate;
});

final searchTemplatesProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = Provider((ref) {
  final query = ref.watch(searchTemplatesProvider);
  final notifier = ref.read(templateProvider.notifier);
  return notifier.searchTemplates(query);
});

// ─── Pagination Support ──────────────────────────────────────────────────

// State for pagination: (categoryId, page, perPage)
final templatePaginationPageProvider =
    StateProvider.family<int, String>((ref, categoryId) => 1);

// Provider for paginated templates by category
final paginatedTemplatesByCategoryProvider = FutureProvider.family<dynamic,
    ({String categoryId, int page, int perPage})>((ref, params) async {
  final service = ref.read(templateServiceProvider);
  final response = await service.fetchTemplatesByCategory(
    params.categoryId,
    page: params.page,
    perPage: params.perPage,
  );
  return response;
});

// Convenience provider that uses the state for current page
final templatesByCategoryPaginatedProvider =
    FutureProvider.family<dynamic, ({String categoryId, int perPage})>(
        (ref, params) async {
  final currentPage =
      ref.watch(templatePaginationPageProvider(params.categoryId));
  final service = ref.read(templateServiceProvider);
  final response = await service.fetchTemplatesByCategory(
    params.categoryId,
    page: currentPage,
    perPage: params.perPage,
  );
  return response;
});
