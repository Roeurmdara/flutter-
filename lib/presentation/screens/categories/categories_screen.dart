import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/category_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF6F5F3),
      appBar: AppBar(
        title: const Text('Discover Habits'),
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      ),
      body: categoriesAsync.when(
        loading: () => _buildLoadingState(isDark),
        error: (error, stack) => _buildErrorState(error.toString(), isDark, ref),
        data: (categories) => categories.isEmpty
            ? _buildEmptyState(isDark)
            : _buildCategoriesList(categories, isDark, ref),
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label shimmer
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Shimmer.fromColors(
                baseColor: isDark ? AppColors.darkBorder : Colors.grey[300]!,
                highlightColor: isDark ? AppColors.darkSurface : Colors.grey[100]!,
                child: Container(
                  height: 32,
                  width: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Cards shimmer row
            SizedBox(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: 3,
                itemBuilder: (_, __) => Shimmer.fromColors(
                  baseColor: isDark ? AppColors.darkBorder : Colors.grey[300]!,
                  highlightColor: isDark ? AppColors.darkSurface : Colors.grey[100]!,
                  child: Container(
                    width: 155,
                    margin: const EdgeInsets.only(right: 12),
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

  Widget _buildErrorState(String error, bool isDark, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48,
              color: AppColors.primaryPurple.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text('Failed to load categories',
              style: AppTypography.titleMedium(
                  isDark ? AppColors.darkText : AppColors.lightText)),
          const SizedBox(height: 8),
          Text(error,
              style: AppTypography.bodySmall(
                  isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => ref.refresh(categoriesProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Text('No categories available',
          style: AppTypography.titleMedium(
              isDark ? AppColors.darkText : AppColors.lightText)),
    );
  }

  Widget _buildCategoriesList(
      List<dynamic> categories, bool isDark, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 24),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategorySection(category: category, isDark: isDark);
      },
    );
  }
}

class _CategorySection extends ConsumerWidget {
  final dynamic category;
  final bool isDark;

  const _CategorySection({required this.category, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryId = category.id as String;
    final templatesAsync = ref.watch(categoryTemplatesProvider(categoryId));
    final categoryColor = _hexToColor(category.colorHex as String);

    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category label ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      category.icon as String? ?? '📌',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  category.name as String,
                  style: AppTypography.titleMedium(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Template cards row ───────────────────────────────────────
          templatesAsync.when(
            loading: () => _buildCardsShimmer(isDark),
            error: (_, __) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Failed to load templates',
                  style: AppTypography.bodySmall(isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary)),
            ),
            data: (templates) {
              if (templates.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text('No templates yet',
                      style: AppTypography.bodySmall(isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary)),
                );
              }
              return SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: templates.length,
                  itemBuilder: (context, i) => _TemplateCard(
                    template: templates[i],
                    categoryColor: categoryColor,
                    isDark: isDark,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardsShimmer(bool isDark) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: isDark ? AppColors.darkBorder : Colors.grey[300]!,
          highlightColor: isDark ? AppColors.darkSurface : Colors.grey[100]!,
          child: Container(
            width: 155,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
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
}

class _TemplateCard extends StatefulWidget {
  final dynamic template;
  final Color categoryColor;
  final bool isDark;

  const _TemplateCard({
    required this.template,
    required this.categoryColor,
    required this.isDark,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    final freq = widget.template.suggestedFrequency as String? ?? 'daily';
    final days = widget.template.durationDays as int? ?? 1;

    return GestureDetector(
      onTap: () {
        setState(() => _added = !_added);
        // TODO: dispatch add/remove habit from template action
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _added
                  ? '${widget.template.title} added to your habits'
                  : '${widget.template.title} removed',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 155,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkSurface : Colors.white,
          border: Border.all(
            color: _added
                ? Colors.green.withOpacity(0.6)
                : widget.isDark
                    ? AppColors.darkBorder
                    : AppColors.lightBorder,
            width: _added ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Frequency badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                freq[0].toUpperCase() + freq.substring(1),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: widget.categoryColor,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Title
            Text(
              widget.template.title as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleSmall(
                widget.isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 5),

            // Description
            Expanded(
              child: Text(
                widget.template.description as String? ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.bodySmall(
                  widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Footer: days + add button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$days days',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _added
                        ? Colors.green.withOpacity(0.12)
                        : widget.categoryColor.withOpacity(0.1),
                    border: Border.all(
                      color: _added
                          ? Colors.green.withOpacity(0.5)
                          : widget.categoryColor.withOpacity(0.4),
                    ),
                  ),
                  child: Icon(
                    _added ? Icons.check : Icons.add,
                    size: 15,
                    color: _added ? Colors.green : widget.categoryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}