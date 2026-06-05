import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/habit_template_model.dart';
import '../../../data/providers/habit_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APITemplateCard  (unchanged)
// ─────────────────────────────────────────────────────────────────────────────
class APITemplateCard extends StatefulWidget {
  final HabitTemplate template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;

  const APITemplateCard({
    super.key,
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
    required this.isDark,
  });

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
    final isDark = widget.isDark;

    final Color textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final Color textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 148,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border.all(
          color: _added
              ? const Color(0xFF63993B).withOpacity(0.8)
              : isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
          width: _added ? 1.5 : 0.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title ──────────────────────────────────────────────────
          Text(
            widget.template.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.25,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 6),

          // ── Frequency row ──────────────────────────────────────────
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 12, color: textSecondary),
              const SizedBox(width: 4),
              Text(
                freqLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: textSecondary,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ── Bottom row: icon circle + arrow circle ─────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Category icon with colored circle bg
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: widget.categoryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    widget.categoryIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),

              // Arrow — opens detail sheet
              GestureDetector(
                onTap: () => _showDetail(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppColors.primaryPurple
                        : AppColors.primaryPurple,
                  ),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    size: 16,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
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
class APITemplateDetailSheet extends ConsumerStatefulWidget {
  final HabitTemplate template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;
  final bool isAdded;
  final VoidCallback onToggle;

  const APITemplateDetailSheet({
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
  ConsumerState<APITemplateDetailSheet> createState() =>
      _APITemplateDetailSheetState();
}

class _APITemplateDetailSheetState
    extends ConsumerState<APITemplateDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _tipsController;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.template.title);
    // Description and tips are editable — pre-filled from API
    _descriptionController =
        TextEditingController(text: widget.template.description);
    _tipsController = TextEditingController(text: widget.template.tips);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Future<void> _handleCreate() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    setState(() => _isCreating = true);
    try {
      await ref.read(habitsProvider.notifier).createHabit(
            categoryId: widget.template.categoryId,
            title: _titleController.text.trim(),
            // Use the user-edited description & tips
            description: _descriptionController.text.trim(),
            frequencyType: widget.template.recommendedFrequency.toLowerCase(),
            frequencyConfig: [
              widget.template.recommendedFrequency.toLowerCase()
            ],
            goalType: 'binary',
            targetValue: 1,
            targetUnit: 'completion',
            startDate: DateTime.now(),
            endDate: null,
            visibility: 'private',
            emoji: widget.template.icon,
            colorHex: widget.template.color,
          );

      widget.onToggle();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ⚪ Force the text color to be white
            content: Text(
              '${_titleController.text.trim()} added to habits',
              style: const TextStyle(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
      
            backgroundColor: AppColors.primaryPurple,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
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

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final template = widget.template;

    // Values read directly from API — not editable, not cycled
    final freqLabel = _capitalize(template.recommendedFrequency);
    final durationLabel = '${template.recommendedDuration} days';

    final Color bg = isDark ? AppColors.darkSurface : const Color(0xFFFAFAFA);
    final Color textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final Color textSecondary =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final Color divider =
        isDark ? Colors.white10 : Colors.black.withOpacity(0.06);
    final Color inputFill = isDark
        ? Colors.white.withOpacity(0.04)
        : Colors.black.withOpacity(0.03);

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
              // ── Drag handle ──────────────────────────────────────────────
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header ───────────────────────────────────────────────────
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
                              : Colors.black.withOpacity(0.05),
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

              // ── Scrollable body ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TEMPLATE INFO ROW
                      _buildLabel('TEMPLATE', isDark),
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: widget.categoryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: widget.categoryColor.withOpacity(0.25),
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
                                  template.title,
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
                                  isDark: isDark,
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
                                  label: durationLabel,
                                  isDark: isDark,
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

                      if (template.tips.isNotEmpty) ...[
                        _buildLabel('TIPS', isDark),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 2),
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

                      // TAGS — read-only from API
                      if (template.tags.isNotEmpty) ...[
                        _buildLabel('TAGS', isDark),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: template.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: widget.categoryColor.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: widget.categoryColor.withOpacity(0.2),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.categoryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
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
                                AppColors.primaryPurple.withOpacity(0.5),
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

  // ── Sub-builders ──────────────────────────────────────────────────────────

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

  /// Read-only display box — used for Frequency and Duration (from API).
  Widget _buildReadOnlyBox({
    required String label,
    required bool isDark,
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
