import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/models/activity_model.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/providers/activity_provider.dart';
import 'create_habit_form_fields.dart';
import 'create_habit_pickers.dart';

class CreateHabitModal extends ConsumerStatefulWidget {
  final Habit? editingHabit;
  final Function(Map<String, dynamic> data)? onSubmit;
  final VoidCallback? onDelete;

  const CreateHabitModal({
    super.key,
    this.editingHabit,
    this.onSubmit,
    this.onDelete,
  });

  @override
  ConsumerState<CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends ConsumerState<CreateHabitModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _activityTypeController;
  late TextEditingController _activityNoteController;

  String? _selectedCategoryId;
  String _selectedFrequency = 'daily';
  final List<String> _frequencies = ['daily', 'weekly', 'monthly'];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  bool _addActivity = false;
  bool _showActivityForm = false;
  DateTime _activitySettlementDate = DateTime.now();
  List<Activity> _createdActivities = [];
  Habit? _createdHabit;

  Color _customColor = AppColors.primaryPurple;
  String _customEmoji = '✨';

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.editingHabit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.editingHabit?.description ?? '');
    _activityTypeController = TextEditingController();
    _activityNoteController = TextEditingController();
    _createdActivities = [];
    _selectedCategoryId = widget.editingHabit?.categoryId;
    _selectedFrequency = widget.editingHabit?.frequency ?? 'daily';
    _startDate = dateOnly(widget.editingHabit?.startDate ?? DateTime.now());
    _endDate = widget.editingHabit?.endDate != null
        ? dateOnly(widget.editingHabit!.endDate!)
        : null;

    // Load custom emoji and color if editing existing habit
    if (widget.editingHabit != null) {
      if (widget.editingHabit!.emoji != null) {
        _customEmoji = widget.editingHabit!.emoji!;
      }
      if (widget.editingHabit!.colorHex != null) {
        try {
          _customColor = Color(int.parse(
                  widget.editingHabit!.colorHex!.replaceFirst('#', ''),
                  radix: 16) +
              0xFF000000);
        } catch (e) {
          _customColor = AppColors.primaryPurple;
        }
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(activitiesNotifierProvider.notifier)
            .loadActivities(widget.editingHabit!.id, _activitySettlementDate);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _activityTypeController.dispose();
    _activityNoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final activityState = ref.watch(activitiesNotifierProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.55,
      maxChildSize: 0.90,
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
              const SizedBox(height: 18),

              // ── Header ───────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.editingHabit != null ? 'Edit Habit' : 'New Habit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
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
              const SizedBox(height: 8),
              Divider(
                height: 1,
                color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
              ),

              // ── Body ─────────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      buildLabel('TITLE', isDark),
                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: buildInputDecoration(isDark,
                            hint: 'e.g. Morning run'),
                      ),
                      const SizedBox(height: 18),

                      // DESCRIPTION
                      buildLabel('DESCRIPTION', isDark),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: buildInputDecoration(isDark,
                            hint: 'Optional notes...'),
                      ),
                      const SizedBox(height: 18),

                      // CATEGORY
                      buildLabel('CATEGORY', isDark),
                      CategoryDropdown(
                        isDark: isDark,
                        selectedCategoryId: _selectedCategoryId,
                        onChanged: (value) =>
                            setState(() => _selectedCategoryId = value),
                      ),
                      const SizedBox(height: 18),

                      // FREQUENCY
                      buildLabel('FREQUENCY', isDark),
                      FrequencyDropdown(
                        isDark: isDark,
                        selectedFrequency: _selectedFrequency,
                        frequencies: _frequencies,
                        onChanged: (value) =>
                            setState(() => _selectedFrequency = value),
                      ),
                      const SizedBox(height: 18),

                      // CUSTOMIZE
                      buildLabel('CUSTOMIZE', isDark),
                      _buildCustomizeRow(isDark),
                      const SizedBox(height: 18),

                      // DATES
                      Row(
                        children: [
                          Expanded(
                            child: HabitDateField(
                              isDark: isDark,
                              label: 'START',
                              date: _startDate,
                              onChanged: (d) {
                                if (d != null) setState(() => _startDate = d);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: HabitDateField(
                              isDark: isDark,
                              label: 'END',
                              date: _endDate,
                              onChanged: (d) => setState(() => _endDate = d),
                              isOptional: true,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // ACTIVITY TOGGLE
                      SwitchListTile.adaptive(
                        value: _addActivity,
                        onChanged: (v) => setState(() {
                          _addActivity = v;
                          if (!v) _showActivityForm = false;
                        }),
                        title: Text(
                          'Add activity for this habit',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),

                      if (_addActivity) ...[
                        const SizedBox(height: 8),
                        _buildActivityFields(isDark, activityState),
                      ],

                      // Created activities list
                      if (_createdActivities.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        ..._createdActivities.map(
                            (act) => _ActivityCard(act: act, isDark: isDark)),
                      ],

                      const SizedBox(height: 12),

                      // SAVE / CREATE BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _handleSubmit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            widget.editingHabit != null
                                ? 'Save Changes'
                                : 'Create Habit',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // DELETE BUTTON
                      if (widget.editingHabit != null &&
                          widget.onDelete != null) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: TextButton(
                            onPressed: widget.onDelete,
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Delete Habit',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // ── Customize row ────────────────────────────────────────────────────────────
  Widget _buildCustomizeRow(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => showHabitColorPicker(
              context: context,
              isDark: isDark,
              currentColor: _customColor,
              onColorSelected: (color) => setState(() => _customColor = color),
            ),
            child: _customizeItem(
              isDark: isDark,
              label: 'Color',
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _customColor,
                  border: Border.all(
                      color: _customColor.withOpacity(0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: _customColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.palette_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => showHabitEmojiPicker(
              context: context,
              isDark: isDark,
              currentEmoji: _customEmoji,
              currentColor: _customColor,
              onEmojiSelected: (emoji) => setState(() => _customEmoji = emoji),
            ),
            child: _customizeItem(
              isDark: isDark,
              label: 'Emoji',
              child: _emojiCircle(50),
            ),
          ),
          _customizeItem(
            isDark: isDark,
            label: 'Preview',
            child: _emojiCircle(50),
          ),
        ],
      ),
    );
  }

  Widget _emojiCircle(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _customColor.withOpacity(0.15),
          border: Border.all(color: _customColor.withOpacity(0.3), width: 2),
        ),
        child: Center(
          child: Text(_customEmoji, style: const TextStyle(fontSize: 28)),
        ),
      );

  Widget _customizeItem({
    required bool isDark,
    required String label,
    required Widget child,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
          ),
        ],
      );

  // ── Activity fields ──────────────────────────────────────────────────────────
  Widget _buildActivityFields(bool isDark, dynamic activityState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // + button — only shown before form is revealed
        if (!_showActivityForm)
          GestureDetector(
            onTap: () => setState(() => _showActivityForm = true),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primaryPurple.withOpacity(0.25),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Add activity detail',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Inline form — permanently visible after tapping +
        if (_showActivityForm) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.03)
                  : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLabel('ACTIVITY TYPE', isDark),
                const SizedBox(height: 6),
                TextField(
                  controller: _activityTypeController,
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black),
                  decoration:
                      buildInputDecoration(isDark, hint: 'e.g. Morning run'),
                ),
                const SizedBox(height: 12),
                buildLabel('SETTLEMENT DATE', isDark),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _activitySettlementDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => _activitySettlementDate = picked);
                      if (widget.editingHabit != null) {
                        await ref
                            .read(activitiesNotifierProvider.notifier)
                            .loadActivities(widget.editingHabit!.id, picked);
                      }
                    }
                  },
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.04)
                          : Colors.black.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: isDark ? Colors.white12 : Colors.black12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14,
                            color: AppColors.primaryPurple.withOpacity(0.7)),
                        const SizedBox(width: 8),
                        Text(
                          '${_activitySettlementDate.day}/${_activitySettlementDate.month}/${_activitySettlementDate.year}',
                          style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white : Colors.black),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                buildLabel('NOTE', isDark),
                const SizedBox(height: 6),
                TextField(
                  controller: _activityNoteController,
                  maxLines: 2,
                  style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.black),
                  decoration:
                      buildInputDecoration(isDark, hint: 'Optional note...'),
                ),
              ],
            ),
          ),
        ],

        // Existing activities
        if (widget.editingHabit != null &&
            activityState.activities.isNotEmpty) ...[
          const SizedBox(height: 20),
          buildLabel('EXISTING ACTIVITIES', isDark),
          const SizedBox(height: 6),
          ...activityState.activities.reversed
              .map<Widget>((act) => _ActivityCard(act: act, isDark: isDark))
              .toList(),
        ],
      ],
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────────
  Future<void> _handleSubmit() async {
    if (_titleController.text.trim().isEmpty) {
      _showSnack('Please enter a title');
      return;
    }

    if (widget.editingHabit != null && widget.onSubmit != null) {
      widget.onSubmit!({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'categoryId': _selectedCategoryId,
        'frequencyType': _selectedFrequency,
        'frequencyConfig': [_selectedFrequency],
        'startDate': _startDate,
        'endDate': _endDate,
        'color':
            '#${_customColor.value.toRadixString(16).substring(2).toUpperCase()}',
        'emoji': _customEmoji,
      });

      if (_addActivity && _activityTypeController.text.trim().isNotEmpty) {
        await _createActivity(widget.editingHabit!.id);
      }

      if (mounted) Navigator.pop(context);
      return;
    }

    if (_selectedCategoryId == null) {
      _showSnack('Please select a category');
      return;
    }

    try {
      final colorHex =
          '#${_customColor.value.toRadixString(16).substring(2).toUpperCase()}';
      final newHabit = await ref.read(habitsProvider.notifier).createHabit(
            categoryId: _selectedCategoryId!,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            frequencyType: _selectedFrequency,
            frequencyConfig: [_selectedFrequency],
            goalType: 'binary',
            targetValue: 1,
            targetUnit: 'completion',
            startDate: _startDate,
            endDate: _endDate,
            visibility: 'private',
            emoji: _customEmoji,
            colorHex: colorHex,
          );
      setState(() => _createdHabit = newHabit);

      if (_addActivity && _activityTypeController.text.trim().isNotEmpty) {
        await _createActivity(newHabit.id);
        await ref
            .read(activitiesNotifierProvider.notifier)
            .loadActivities(newHabit.id, _activitySettlementDate);
      }
      if (mounted) {
        _showSnack('Habit created', color: AppColors.primaryPurple);
        if (!_addActivity) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e', color: AppColors.error);
    }
  }

  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          // ⚪ Force the text color to be white
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: color ?? AppColors.primaryPurple.withOpacity(0.7),
      ),
    );
  }

  Future<void> _createActivity(String habitId) async {
    try {
      final created =
          await ref.read(activitiesNotifierProvider.notifier).createActivity(
                habitId: habitId,
                activityType: _activityTypeController.text.trim(),
                value: '1',
                unit: 'completion',
                settlementPeriodDate: _activitySettlementDate,
                note: _activityNoteController.text.trim().isEmpty
                    ? null
                    : _activityNoteController.text.trim(),
              );
      setState(() {
        _createdActivities.insert(0, created);
        _showActivityForm = false;
        _activityTypeController.clear();
        _activityNoteController.clear();
      });
      if (mounted) _showSnack('Activity created');
    } catch (e) {
      if (mounted) _showSnack('Activity creation failed: $e');
    }
  }
}

// ── Expandable activity card (existing activities) ────────────────────────────
class _ActivityCard extends StatefulWidget {
  final Activity act;
  final bool isDark;

  const _ActivityCard({required this.act, required this.isDark, super.key});

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final act = widget.act;
    final isDark = widget.isDark;

    return Container(
      key: ValueKey(act.id),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: AppColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          act.activityType,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${act.settlementPeriodDate.day}/${act.settlementPeriodDate.month}/${act.settlementPeriodDate.year}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _expanded
                          ? AppColors.primaryPurple.withOpacity(0.12)
                          : (isDark
                              ? Colors.white.withOpacity(0.06)
                              : Colors.black.withOpacity(0.05)),
                      border: Border.all(
                        color: _expanded
                            ? AppColors.primaryPurple.withOpacity(0.4)
                            : (isDark ? Colors.white24 : Colors.black12),
                      ),
                    ),
                    child: AnimatedRotation(
                      turns: _expanded ? 0.125 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: _expanded
                            ? AppColors.primaryPurple
                            : (isDark ? Colors.white54 : Colors.black45),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Detail ────────────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color:
                        isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow('ACTIVITY', act.activityType, isDark),
                  const SizedBox(height: 8),
                  _detailRow(
                    'DATE',
                    '${act.settlementPeriodDate.day} / ${act.settlementPeriodDate.month} / ${act.settlementPeriodDate.year}',
                    isDark,
                  ),
                  if ((act.note ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _detailRow('NOTE', act.note!, isDark),
                  ],
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 0.4,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ),
      ],
    );
  }
}
