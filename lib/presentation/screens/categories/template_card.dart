import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/habit_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TemplateCard
// ─────────────────────────────────────────────────────────────────────────────
class TemplateCard extends StatefulWidget {
  final dynamic template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;

  const TemplateCard({
    super.key,
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
    required this.isDark,
  });

  @override
  State<TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<TemplateCard> {
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

  @override
  Widget build(BuildContext context) {
    final freq = widget.template.suggestedFrequency as String? ?? 'daily';
    final days = widget.template.durationDays as int? ?? 1;
    final freqLabel = freq[0].toUpperCase() + freq.substring(1);
    final isDark = widget.isDark;

    final Color surface = isDark ? AppColors.darkSurface : Colors.white;
    final Color textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final Color textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color borderColor = _added
        ? const Color(0xFF63993B).withValues(alpha: 0.7)
        : isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 152,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        border: Border.all(color: borderColor, width: _added ? 1.5 : 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ────────────────────────────────────────────────────
          Text(
            widget.template.title as String,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // ── Frequency row: clock icon + label ────────────────────────
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '$freqLabel · $days d',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── Bottom row: icon circle + arrow circle ───────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Category icon with colored circle bg
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.categoryColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.categoryIcon,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),

              // Arrow detail button — dark circle
              GestureDetector(
                onTap: () => _showDetail(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 18,
                    color: isDark ? Colors.black : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TemplateDetailSheet
// ─────────────────────────────────────────────────────────────────────────────
class TemplateDetailSheet extends ConsumerStatefulWidget {
  final dynamic template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;
  final bool isAdded;
  final VoidCallback onToggle;

  const TemplateDetailSheet({
    super.key,
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
    required this.isDark,
    required this.isAdded,
    required this.onToggle,
  });

  @override
  ConsumerState<TemplateDetailSheet> createState() =>
      _TemplateDetailSheetState();
}

class _TemplateDetailSheetState extends ConsumerState<TemplateDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tipsController;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.template.title as String? ?? '');
    _descriptionController = TextEditingController(
        text: widget.template.description as String? ?? '');
    // tips is List — join for editing, split back on save if needed
    final tips = widget.template.tips as List<dynamic>? ?? [];
    _tipsController =
        TextEditingController(text: tips.map((t) => t.toString()).join('\n'));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      final frequency =
          widget.template.suggestedFrequency as String? ?? 'daily';

      // Compute explicit endDate from template duration so client-side
      // date-range logic (endDate exclusive) hides the habit correctly.
      final durationDays = widget.template.durationDays as int? ?? 1;
      final now = DateTime.now();
      final startDateOnly = DateTime(now.year, now.month, now.day);
      final computedEndDate = startDateOnly.add(Duration(days: durationDays));

      await ref.read(habitsProvider.notifier).createHabit(
            categoryId: widget.template.categoryId as String,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            frequencyType: frequency,
            frequencyConfig: [frequency],
            goalType: 'binary',
            targetValue: 1,
            targetUnit: 'completion',
            startDate: DateTime.now(),
            endDate: computedEndDate,
            visibility: 'private',
            emoji: widget.template.emoji as String? ?? widget.categoryIcon,
            colorHex: widget.template.colorHex as String? ??
                '#${widget.categoryColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
          );

      widget.onToggle();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${_titleController.text.trim()} added to your habits'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final template = widget.template;

    // Read-only from API
    final freq = template.suggestedFrequency as String? ?? 'daily';
    final days = template.durationDays as int? ?? 1;
    final freqLabel = freq[0].toUpperCase() + freq.substring(1);
    final benefits = template.benefits as List<dynamic>? ?? [];
    final hasTips = (template.tips as List<dynamic>? ?? []).isNotEmpty;

    final Color bg = isDark ? AppColors.darkSurface : Colors.white;
    final Color textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final Color textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color divider =
        isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06);
    final Color inputFill = isDark
        ? Colors.white.withValues(alpha: 0.04)
        : Colors.black.withValues(alpha: 0.03);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ────────────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header ─────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create from Template',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white10
                              : Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: divider),

              // ── Body ───────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TEMPLATE INFO
                      _buildLabel('TEMPLATE', isDark),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color:
                                  widget.categoryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: widget.categoryColor
                                    .withValues(alpha: 0.25),
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                widget.categoryIcon,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.categoryName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: widget.categoryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  template.title as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // HABIT TITLE — editable
                      _buildLabel('HABIT TITLE', isDark),
                      TextField(
                        controller: _titleController,
                        enabled: !_isCreating,
                        style: TextStyle(fontSize: 14, color: textPrimary),
                        decoration: _buildInputDecoration(
                          isDark,
                          hint: 'e.g. Morning run',
                          inputFill: inputFill,
                          divider: divider,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // DESCRIPTION — editable, pre-filled from API
                      _buildLabel('DESCRIPTION', isDark),
                      TextField(
                        controller: _descriptionController,
                        enabled: !_isCreating,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 13,
                          color: textPrimary,
                          height: 1.5,
                        ),
                        decoration: _buildInputDecoration(
                          isDark,
                          hint: 'Optional notes...',
                          inputFill: inputFill,
                          divider: divider,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // FREQUENCY & DURATION — read-only from API
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('FREQUENCY', isDark),
                                _buildReadOnlyBox(
                                  label: freqLabel,
                                  textPrimary: textPrimary,
                                  inputFill: inputFill,
                                  divider: divider,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('DURATION', isDark),
                                _buildReadOnlyBox(
                                  label: '$days days',
                                  textPrimary: textPrimary,
                                  inputFill: inputFill,
                                  divider: divider,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // BENEFITS — read-only from API
                      if (benefits.isNotEmpty) ...[
                        _buildLabel('BENEFITS', isDark),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: inputFill,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: divider, width: 0.5),
                          ),
                          child: Column(
                            children: benefits.map((b) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5),
                                      child: Container(
                                        width: 4,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: widget.categoryColor
                                              .withValues(alpha: 0.5),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        b.toString(),
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.5,
                                          color: textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],

                      // TIPS — editable, pre-filled from API
                      if (hasTips) ...[
                        _buildLabel('TIPS', isDark),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 11),
                              child: Text('💡', style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _tipsController,
                                enabled: !_isCreating,
                                maxLines: 3,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textPrimary,
                                  height: 1.5,
                                ),
                                decoration: _buildInputDecoration(
                                  isDark,
                                  hint: 'Add a tip...',
                                  inputFill: inputFill,
                                  divider: divider,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                      ],

                      const SizedBox(height: 4),

                      // ADD TO HABITS button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _isCreating ? null : _handleCreate,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            disabledBackgroundColor:
                                AppColors.primaryPurple.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _isCreating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Add to Habits',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Sub-builders ────────────────────────────────────────────────────────────

  Widget _buildLabel(String label, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
    );
  }

  Widget _buildReadOnlyBox({
    required String label,
    required Color textPrimary,
    required Color inputFill,
    required Color divider,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: inputFill,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: divider, width: 0.5),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    bool isDark, {
    required String hint,
    required Color inputFill,
    required Color divider,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: isDark ? Colors.white30 : Colors.black26,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      filled: true,
      fillColor: inputFill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: isDark ? Colors.white38 : Colors.black26,
        ),
      ),
    );
  }
}
