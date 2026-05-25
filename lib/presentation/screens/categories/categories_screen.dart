import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/category_providers.dart';

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
      backgroundColor:
          isDark ? AppColors.darkBackground : const Color(0xFFF6F5F3),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Library',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.08,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            Text(
              'Discover habits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
        toolbarHeight: 64,
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            height: 0.5,
            thickness: 0.5,
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
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
                baseColor:
                    isDark ? AppColors.darkBorder : Colors.grey[300]!,
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
                  baseColor:
                      isDark ? AppColors.darkBorder : Colors.grey[300]!,
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
              color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
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
      itemBuilder: (context, index) => _CategorySection(
        category: categories[index],
        isDark: isDark,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _CategorySection
// ─────────────────────────────────────────────────────────────────────────────
class _CategorySection extends ConsumerWidget {
  final dynamic category;
  final bool isDark;

  const _CategorySection({required this.category, required this.isDark});

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
    final templatesAsync = ref.watch(categoryTemplatesProvider(categoryId));
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
                  color:
                      isDark ? AppColors.darkSurface : Colors.white,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
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
        templatesAsync.when(
          loading: () => _buildShimmer(isDark),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Failed to load',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          data: (templates) {
            if (templates.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'No templates yet',
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
                itemBuilder: (context, i) => _TemplateCard(
                  template: templates[i],
                  categoryColor: categoryColor,
                  categoryName: category.name as String,
                  categoryIcon: category.icon as String? ?? '📌',
                  isDark: isDark,
                ),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TemplateCard
// ─────────────────────────────────────────────────────────────────────────────
class _TemplateCard extends StatefulWidget {
  final dynamic template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;

  const _TemplateCard({
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
    required this.isDark,
  });

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _added = false;

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TemplateDetailSheet(
        template: widget.template,
        categoryColor: widget.categoryColor,
        categoryName: widget.categoryName,
        categoryIcon: widget.categoryIcon,
        isDark: widget.isDark,
        isAdded: _added,
        onToggle: () => setState(() => _added = !_added),
      ),
    );
  }

  void _toggleAdd(BuildContext context) {
    setState(() => _added = !_added);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _added
              ? '${widget.template.title} added to your habits'
              : '${widget.template.title} removed',
          style: const TextStyle(fontSize: 13),
        ),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final freq = widget.template.suggestedFrequency as String? ?? 'daily';
    final days = widget.template.durationDays as int? ?? 1;
    final freqLabel = freq[0].toUpperCase() + freq.substring(1);

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 148,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          color: widget.isDark ? AppColors.darkSurface : Colors.white,
          border: Border.all(
            color: _added
                ? const Color(0xFF63993B).withOpacity(0.8)
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: widget.categoryColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                freqLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                  color: widget.categoryColor,
                ),
              ),
            ),
            const SizedBox(height: 9),

            // Title
            Text(
              widget.template.title as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: widget.isDark
                    ? AppColors.darkText
                    : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 5),

            // Description
            Expanded(
              child: Text(
                widget.template.description as String? ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$days days',
                  style: TextStyle(
                    fontSize: 10,
                    color: (widget.isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary)
                        .withOpacity(0.6),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleAdd(context),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: _added
                            ? const Color(0xFF63993B).withOpacity(0.7)
                            : widget.isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      _added ? Icons.check : Icons.add,
                      size: 13,
                      color: _added
                          ? const Color(0xFF63993B)
                          : widget.isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                    ),
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

// ─────────────────────────────────────────────────────────────────────────────
// TemplateDetailSheet  —  bottom sheet shown on card tap
// ─────────────────────────────────────────────────────────────────────────────
class TemplateDetailSheet extends StatefulWidget {
  final dynamic template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;
  final bool isAdded;
  final VoidCallback onToggle;

  const TemplateDetailSheet({
    Key? key,
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
    required this.isDark,
    required this.isAdded,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<TemplateDetailSheet> createState() => _TemplateDetailSheetState();
}

class _TemplateDetailSheetState extends State<TemplateDetailSheet> {
  late bool _added;

  @override
  void initState() {
    super.initState();
    _added = widget.isAdded;
  }

  void _handleToggle() {
    setState(() => _added = !_added);
    widget.onToggle();
    if (_added) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final template = widget.template;
    final freq = template.suggestedFrequency as String? ?? 'daily';
    final days = template.durationDays as int? ?? 1;
    final freqLabel = freq[0].toUpperCase() + freq.substring(1);
    final title = template.title as String;
    final description = template.description as String? ?? '';
    final tips = template.tips as List<dynamic>? ?? [];
    final benefits = template.benefits as List<dynamic>? ?? [];

    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──────────────────────────────────────────────────
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Scrollable content ───────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category chip
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.categoryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: widget.categoryColor.withOpacity(0.25),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.categoryIcon,
                                style: const TextStyle(fontSize: 12)),
                            const SizedBox(width: 5),
                            Text(
                              widget.categoryName,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: widget.categoryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Freq badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.categoryColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          freqLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: widget.categoryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Stats row ───────────────────────────────────────────
                  Row(
                    children: [
                      _StatChip(
                        label: 'Duration',
                        value: '$days days',
                        color: widget.categoryColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        label: 'Frequency',
                        value: freqLabel,
                        color: widget.categoryColor,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _StatChip(
                        label: 'Effort',
                        value: _effortLabel(days),
                        color: widget.categoryColor,
                        isDark: isDark,
                      ),
                    ],
                  ),

                  // ── Benefits ────────────────────────────────────────────
                  if (benefits.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'Benefits', textSecondary: textSecondary),
                    const SizedBox(height: 12),
                    ...benefits.map((b) => _BulletRow(
                          text: b.toString(),
                          color: widget.categoryColor,
                          textPrimary: textPrimary,
                        )),
                  ],

                  // ── Tips ────────────────────────────────────────────────
                  if (tips.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'Tips', textSecondary: textSecondary),
                    const SizedBox(height: 12),
                    ...tips.map((t) => _BulletRow(
                          text: t.toString(),
                          color: widget.categoryColor,
                          textPrimary: textPrimary,
                        )),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Action button ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
                24, 12, 24, MediaQuery.of(context).padding.bottom + 20),
            child: GestureDetector(
              onTap: _handleToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: _added
                      ? Colors.transparent
                      : widget.categoryColor,
                  border: Border.all(
                    color: _added
                        ? const Color(0xFF63993B).withOpacity(0.6)
                        : widget.categoryColor,
                    width: _added ? 1.0 : 0,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _added ? Icons.check : Icons.add,
                        size: 16,
                        color: _added
                            ? const Color(0xFF63993B)
                            : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _added ? 'Added to habits' : 'Add habit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _added
                              ? const Color(0xFF63993B)
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _effortLabel(int days) {
    if (days <= 14) return 'Light';
    if (days <= 30) return 'Moderate';
    return 'Committed';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets for the detail sheet
// ─────────────────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.18), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textSecondary;

  const _SectionLabel({required this.label, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.08,
        color: textSecondary,
      ),
    );
  }
}

class _BulletRow extends StatelessWidget {
  final String text;
  final Color color;
  final Color textPrimary;

  const _BulletRow({
    required this.text,
    required this.color,
    required this.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: color.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}