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
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
  // Updated to use AppColors.lightBackground to match the community screen exactly
  backgroundColor:
      isDark ? AppColors.darkBackground : AppColors.lightBackground,
  appBar: AppBar(
    backgroundColor:
        isDark ? AppColors.darkSurface : Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0, // Keeps background solid when scrolling
    toolbarHeight: 60, // Matched with the community screen for consistency
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discover habits',
          style: TextStyle(
            fontSize: 19, // Matched sizing
            fontWeight: FontWeight.w600, // Matched font weight
            color: isDark ? AppColors.darkText : AppColors.lightText,
            letterSpacing: -0.3,
          ),
        ),
      ],
    ),
    // Removed the harsh divider completely to match the cleaner community screen style
  ),
  body: categoriesAsync.when(
    loading: () => _buildLoadingState(isDark),
    error: (error, stack) =>
        _buildErrorState(error.toString(), isDark, ref),
    data: (categories) => categories.isEmpty
        ? _buildEmptyState(isDark)
        : _buildCategoriesList(categories, isDark, ref),
  ),
);
  }

  // ── Loading state ──────────────────────────────────────────────────────────
  Widget _buildLoadingState(bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 28),
      itemCount: 3,
      separatorBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Divider(
          height: 0.5,
          thickness: 0.5,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Column(
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

// ─────────────────────────────────────────────────────────────────────────────
// CategorySection
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
    final apiTemplatesAsync = ref.watch(templatesByCategoryProvider(categoryId));
    final categoryColor = _hexToColor(category.colorHex as String);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ────────────────────────────────────────────────────────────
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

        // ── Templates row ─────────────────────────────────────────────────────
        apiTemplatesAsync.when(
          loading: () => _buildShimmer(isDark),
          error: (error, stackTrace) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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