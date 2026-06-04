import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TemplateHabitCard  —  standalone card widget
//
// Usage:
//   TemplateHabitCard(
//     template: myTemplate,
//     categoryColor: Color(0xFF63993B),
//     categoryName: 'Fitness',
//     categoryIcon: '🏋️',
//     isDark: false,
//   )
//
// The card manages its own "added" state internally. If you need to hoist
// state, pass [isAdded] and [onToggle] explicitly.
// ─────────────────────────────────────────────────────────────────────────────

// ─── Minimal colour tokens (replace with your AppColors import) ───────────────
class _Colors {
  static const darkBackground = Color(0xFF111111);
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkBorder = Color(0xFF2C2C2E);
  static const darkText = Color(0xFFF2F2F7);
  static const darkTextSecondary = Color(0xFF8E8E93);

  static const lightBorder = Color(0xFFE5E5EA);
  static const lightText = Color(0xFF1C1C1E);
  static const lightTextSecondary = Color(0xFF6C6C70);

  static const addedGreen = Color(0xFF63993B);
}

// ─── Template data contract ───────────────────────────────────────────────────
/// Wrap your actual model or pass a plain [Map] by implementing this interface.
abstract class HabitTemplate {
  String get title;
  String? get description;
  String? get suggestedFrequency; // e.g. 'daily', 'weekly'
  int? get durationDays;
  List<String> get tips;
  List<String> get benefits;
}

// ─────────────────────────────────────────────────────────────────────────────
// Public card widget
// ─────────────────────────────────────────────────────────────────────────────
class TemplateHabitCard extends StatefulWidget {
  final HabitTemplate template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;

  /// Optional: control added state externally.
  final bool? isAdded;

  /// Optional: called when the add/remove button is tapped.
  final ValueChanged<bool>? onToggle;

  const TemplateHabitCard({
    super.key,
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
    required this.isDark,
    this.isAdded,
    this.onToggle,
  });

  @override
  State<TemplateHabitCard> createState() => _TemplateHabitCardState();
}

class _TemplateHabitCardState extends State<TemplateHabitCard> {
  late bool _added;

  bool get _isControlled => widget.isAdded != null;

  @override
  void initState() {
    super.initState();
    _added = widget.isAdded ?? false;
  }

  @override
  void didUpdateWidget(covariant TemplateHabitCard old) {
    super.didUpdateWidget(old);
    if (_isControlled) _added = widget.isAdded!;
  }

  void _toggle(BuildContext context) {
    final next = !_added;
    if (!_isControlled) setState(() => _added = next);
    widget.onToggle?.call(next);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          next
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

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TemplateDetailSheet(
        template: widget.template,
        categoryColor: widget.categoryColor,
        categoryName: widget.categoryName,
        categoryIcon: widget.categoryIcon,
        isDark: widget.isDark,
        isAdded: _added,
        onToggle: () {
          final next = !_added;
          if (!_isControlled) setState(() => _added = next);
          widget.onToggle?.call(next);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.template;
    final freq = t.suggestedFrequency ?? 'daily';
    final days = t.durationDays ?? 1;
    final freqLabel = freq[0].toUpperCase() + freq.substring(1);

    final surface =
        widget.isDark ? _Colors.darkSurface : Colors.white;
    final textPrimary =
        widget.isDark ? _Colors.darkText : _Colors.lightText;
    final textSecondary = widget.isDark
        ? _Colors.darkTextSecondary
        : _Colors.lightTextSecondary;
    final border =
        widget.isDark ? _Colors.darkBorder : _Colors.lightBorder;

    return GestureDetector(
      onTap: () => _showDetail(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 148,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
        decoration: BoxDecoration(
          color: surface,
          border: Border.all(
            color: _added
                ? _Colors.addedGreen.withOpacity(0.8)
                : border,
            width: _added ? 1.5 : 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Frequency badge ─────────────────────────────────────────
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

            // ── Title ───────────────────────────────────────────────────
            Text(
              t.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 5),

            // ── Description ─────────────────────────────────────────────
            Expanded(
              child: Text(
                t.description ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  color: textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // ── Footer row ──────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$days days',
                  style: TextStyle(
                    fontSize: 10,
                    color: textSecondary.withOpacity(0.6),
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggle(context),
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
                            ? _Colors.addedGreen.withOpacity(0.7)
                            : border,
                        width: 0.5,
                      ),
                    ),
                    child: Icon(
                      _added ? Icons.check : Icons.add,
                      size: 13,
                      color: _added
                          ? _Colors.addedGreen
                          : textSecondary,
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
// Detail bottom sheet (kept co-located with the card)
// ─────────────────────────────────────────────────────────────────────────────
class _TemplateDetailSheet extends StatefulWidget {
  final HabitTemplate template;
  final Color categoryColor;
  final String categoryName;
  final String categoryIcon;
  final bool isDark;
  final bool isAdded;
  final VoidCallback onToggle;

  const _TemplateDetailSheet({
    required this.template,
    required this.categoryColor,
    required this.categoryName,
    required this.categoryIcon,
    required this.isDark,
    required this.isAdded,
    required this.onToggle,
  });

  @override
  State<_TemplateDetailSheet> createState() => _TemplateDetailSheetState();
}

class _TemplateDetailSheetState extends State<_TemplateDetailSheet> {
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

  String _effortLabel(int days) {
    if (days <= 14) return 'Light';
    if (days <= 30) return 'Moderate';
    return 'Committed';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    final t = widget.template;
    final freq = t.suggestedFrequency ?? 'daily';
    final days = t.durationDays ?? 1;
    final freqLabel = freq[0].toUpperCase() + freq.substring(1);

    final bg = isDark ? _Colors.darkSurface : Colors.white;
    final textPrimary = isDark ? _Colors.darkText : _Colors.lightText;
    final textSecondary =
        isDark ? _Colors.darkTextSecondary : _Colors.lightTextSecondary;
    final border = isDark ? _Colors.darkBorder : _Colors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: border, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ────────────────────────────────────────────────
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

          // ── Scrollable body ────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + frequency chips
                  Row(
                    children: [
                      _CategoryChip(
                        icon: widget.categoryIcon,
                        name: widget.categoryName,
                        color: widget.categoryColor,
                      ),
                      const Spacer(),
                      _FreqChip(label: freqLabel, color: widget.categoryColor),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    t.title,
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
                    t.description ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stat chips
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

                  // Benefits
                  if (t.benefits.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'Benefits', color: textSecondary),
                    const SizedBox(height: 12),
                    ...t.benefits.map((b) => _BulletRow(
                          text: b,
                          color: widget.categoryColor,
                          textPrimary: textPrimary,
                        )),
                  ],

                  // Tips
                  if (t.tips.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _SectionLabel(label: 'Tips', color: textSecondary),
                    const SizedBox(height: 12),
                    ...t.tips.map((tip) => _BulletRow(
                          text: tip,
                          color: widget.categoryColor,
                          textPrimary: textPrimary,
                        )),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── CTA button ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              MediaQuery.of(context).padding.bottom + 20,
            ),
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
                        ? _Colors.addedGreen.withOpacity(0.6)
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
                        color:
                            _added ? _Colors.addedGreen : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _added ? 'Added to habits' : 'Add habit',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _added
                              ? _Colors.addedGreen
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String icon;
  final String name;
  final Color color;

  const _CategoryChip({
    required this.icon,
    required this.name,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 5),
          Text(
            name,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreqChip extends StatelessWidget {
  final String label;
  final Color color;

  const _FreqChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

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
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
  final Color color;

  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.08,
        color: color,
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