import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/category_providers.dart';
import '../../../data/providers/template_provider.dart';
import '../../../data/models/habit_template_model.dart';
import 'api_template_card.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CategoriesScreen
// ─────────────────────────────────────────────────────────────────────────────
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 60,
        title: Text(
          'Discover habits',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          Container(
            color: isDark ? AppColors.darkSurface : Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              decoration: InputDecoration(
                hintText: 'Search templates...',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 18,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
                suffixIcon: _query.isNotEmpty
                    ? GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.04),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                    width: 0.5,
                  ),
                ),
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────────────
          Expanded(
            child: categoriesAsync.when(
              loading: () => _buildLoadingState(isDark),
              error: (error, stack) =>
                  _buildErrorState(error.toString(), isDark, ref),
              data: (categories) {
                if (categories.isEmpty) return _buildEmptyState(isDark);
                // Always watch all category templates so they're cached
                for (final cat in categories) {
                  ref.watch(templatesByCategoryProvider(cat.id as String));
                }
                if (_query.isNotEmpty) {
                  return _buildSearchResults(categories, isDark);
                }
                return _buildCategoriesList(categories, isDark, ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Search results ─────────────────────────────────────────────────────────
  Widget _buildSearchResults(List<dynamic> categories, bool isDark) {
    final results = <_SearchResult>[];

    for (final category in categories) {
      final categoryId = category.id as String;
      final color = _hexToColor(category.colorHex as String);
      final name = category.name as String;
      final icon = category.icon as String? ?? '📌';

      final templatesAsync = ref.watch(templatesByCategoryProvider(categoryId));

      // Only use data that is already loaded — skip loading/error states
      if (templatesAsync is AsyncData) {
        final templates = templatesAsync.value as List<dynamic>;
        for (final t in templates) {
          final template = t as HabitTemplate;
          final matchesTitle = template.title.toLowerCase().contains(_query);
          final matchesDesc =
              template.description.toLowerCase().contains(_query);
          final matchesCategory = name.toLowerCase().contains(_query);
          final matchesTags =
              template.tags.any((tag) => tag.toLowerCase().contains(_query));

          if (matchesTitle || matchesDesc || matchesCategory || matchesTags) {
            results.add(_SearchResult(
              template: template,
              categoryColor: color,
              categoryName: name,
              categoryIcon: icon,
            ));
          }
        }
      }
    }

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 36,
              color: (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)
                  .withOpacity(0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No templates found',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different keyword',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: results.length,
      itemBuilder: (context, i) {
        final r = results[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: APITemplateCard(
            template: r.template,
            categoryColor: r.categoryColor,
            categoryName: r.categoryName,
            categoryIcon: r.categoryIcon,
            isDark: isDark,
          ),
        );
      },
    );
  }

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) {
      buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
    } else {
      buffer.write(hex.replaceFirst('#', ''));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // ── Loading state ──────────────────────────────────────────────────────────
  Widget _buildLoadingState(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 28),
      itemCount: 3,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: Divider(
          height: 0.5,
          thickness: 0.5,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      itemBuilder: (context, index) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Shimmer.fromColors(
              baseColor: isDark ? AppColors.darkBorder : Colors.grey[300]!,
              highlightColor:
                  isDark ? AppColors.darkSurface : Colors.grey[100]!,
              child: Container(
                height: 30,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 168,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              itemBuilder: (_, __) => Shimmer.fromColors(
                baseColor: isDark ? AppColors.darkBorder : Colors.grey[300]!,
                highlightColor:
                    isDark ? AppColors.darkSurface : Colors.grey[100]!,
                child: Container(
                  width: 148,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error state ────────────────────────────────────────────────────────────
  Widget _buildErrorState(String error, bool isDark, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 36,
              color: (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)
                  .withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load categories',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => ref.refresh(categoriesProvider),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ────────────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Text(
        'No categories available',
        style: TextStyle(
          fontSize: 14,
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
      ),
    );
  }

  // ── Categories list ────────────────────────────────────────────────────────
  Widget _buildCategoriesList(
      List<dynamic> categories, bool isDark, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 28),
      itemCount: categories.length,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Divider(
          height: 0.5,
          thickness: 0.5,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      itemBuilder: (context, index) => CategorySection(
        category: categories[index],
        isDark: isDark,
      ),
    );
  }
}

// ── Helper model ──────────────────────────────────────────────────────────────
class _SearchResult {
  final HabitTemplate template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;

  const _SearchResult({
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CategorySection  (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class CategorySection extends ConsumerWidget {
  final dynamic category;
  final bool isDark;

  const CategorySection({
    Key? key,
    required this.category,
    required this.isDark,
  }) : super(key: key);

  Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) {
      buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
    } else {
      buffer.write(hex.replaceFirst('#', ''));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = category.id as String;
    final apiTemplatesAsync =
        ref.watch(templatesByCategoryProvider(categoryId));
    final categoryColor = _hexToColor(category.colorHex as String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  border: Border.all(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    category.icon as String? ?? '📌',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Text(
                category.name as String,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.01,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
        apiTemplatesAsync.when(
          loading: () => _buildShimmer(isDark),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚠️ Failed to load templates',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  error.toString(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? AppColors.darkTextSecondary.withOpacity(0.7)
                        : AppColors.lightTextSecondary.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          data: (templates) {
            if (templates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No templates available',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              );
            }
            return SizedBox(
              height: 168,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: templates.length,
                itemBuilder: (context, i) {
                  final template = templates[i] as HabitTemplate;
                  return APITemplateCard(
                    template: template,
                    categoryColor: categoryColor,
                    categoryName: category.name as String,
                    categoryIcon: category.icon as String? ?? '📌',
                    isDark: isDark,
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildShimmer(bool isDark) {
    return SizedBox(
      height: 168,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: isDark ? AppColors.darkBorder : Colors.grey[300]!,
          highlightColor: isDark ? AppColors.darkSurface : Colors.grey[100]!,
          child: Container(
            width: 148,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
