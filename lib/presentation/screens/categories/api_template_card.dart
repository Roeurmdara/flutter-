import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/habit_template_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APITemplateCard
// ─────────────────────────────────────────────────────────────────────────────
class APITemplateCard extends StatefulWidget {
  final HabitTemplate template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;

  const APITemplateCard({
    Key? key,
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
    required this.isDark,
  }) : super(key: key);

  @override
  State<APITemplateCard> createState() => _APITemplateCardState();
}

class _APITemplateCardState extends State<APITemplateCard> {
  bool _added = false;

  @override
  Widget build(BuildContext context) {
    final freq = widget.template.recommendedFrequency;
    final days = widget.template.recommendedDuration;
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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

            // Icon + Title
            Text(
              '${widget.template.icon} ${widget.template.title}',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: widget.isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 5),

            // Description
            Expanded(
              child: Text(
                widget.template.description,
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
                  onTap: () {
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      ),
                    );
                  },
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

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => APITemplateDetailSheet(
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
}

// ─────────────────────────────────────────────────────────────────────────────
// APITemplateDetailSheet
// ─────────────────────────────────────────────────────────────────────────────
class APITemplateDetailSheet extends StatefulWidget {
  final HabitTemplate template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;
  final bool isAdded;
  final VoidCallback onToggle;

  const APITemplateDetailSheet({
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
  State<APITemplateDetailSheet> createState() => _APITemplateDetailSheetState();
}

class _APITemplateDetailSheetState extends State<APITemplateDetailSheet> {
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
    final freq = template.recommendedFrequency;
    final freqLabel = freq[0].toUpperCase() + freq.substring(1);

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
          // Drag handle
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

          // Content
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
                    '${template.icon} ${template.title}',
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
                    template.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats
                  Row(
                    children: [
                      _StatChip(
                        label: 'Duration',
                        value: '${template.recommendedDuration} days',
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
                    ],
                  ),

                  // Tips
                  if (template.tips.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Text(
                      'Tips',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: border, width: 0.5),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              template.tips,
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.5,
                                color: textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Tags
                  if (template.tags.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: template.tags.map((tag) {
                        return Chip(
                          label: Text(
                            tag,
                            style: TextStyle(fontSize: 11, color: textPrimary),
                          ),
                          backgroundColor:
                              widget.categoryColor.withOpacity(0.1),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action button
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
                  color: _added ? Colors.transparent : widget.categoryColor,
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
                        size: 18,
                        color: _added ? const Color(0xFF63993B) : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _added ? 'Added' : 'Add to Habits',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color:
                              _added ? const Color(0xFF63993B) : Colors.white,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatChip (local, used only in APITemplateDetailSheet)
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