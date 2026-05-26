import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/providers/category_providers.dart';
import './custom_buttons.dart';
import '../../../data/models/habit_category_model.dart';

class CreateHabitModal extends ConsumerStatefulWidget {
  final Habit? editingHabit;
  final Function(Map<String, dynamic> data)? onSubmit;
  final VoidCallback? onDelete;

  const CreateHabitModal({
    Key? key,
    this.editingHabit,
    this.onSubmit,
    this.onDelete,
  }) : super(key: key);

  @override
  ConsumerState<CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends ConsumerState<CreateHabitModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  String? _selectedCategoryId;
  String _selectedFrequency = 'daily';
  final List<String> _frequencies = ['daily', 'weekly', 'monthly'];
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  // Custom color and emoji
  Color _customColor = AppColors.primaryPurple;
  String _customEmoji = '✨';

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.editingHabit?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.editingHabit?.description ?? '');
    _selectedCategoryId = widget.editingHabit?.categoryId;
    _selectedFrequency = widget.editingHabit?.frequency ?? 'daily';
    _startDate = _dateOnly(widget.editingHabit?.startDate ?? DateTime.now());
    _endDate = widget.editingHabit?.endDate != null
        ? _dateOnly(widget.editingHabit!.endDate!)
        : null;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ── Shared input decoration ─────────────────────────────────────────────────
  InputDecoration _inputDecoration(bool isDark,
      {String? hint, Widget? suffix}) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: isDark ? Colors.white12 : Colors.black12,
        width: 1,
      ),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white30 : Colors.black26,
        fontSize: 14,
      ),
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.04)
          : Colors.black.withOpacity(0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: AppColors.primaryPurple.withOpacity(0.6),
          width: 1,
        ),
      ),
      suffixIcon: suffix,
    );
  }

  // ── Section label ───────────────────────────────────────────────────────────
  Widget _label(String text, bool isDark) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.55,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Drag Handle
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

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.editingHabit != null ? 'Edit Habit' : 'New Habit',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),

                    // Close button
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

              // Body
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    28,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      _label('TITLE', isDark),

                      const SizedBox(height: 8),

                      TextField(
                        controller: _titleController,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: _inputDecoration(
                          isDark,
                          hint: 'e.g. Morning run',
                        ),
                      ),

                      const SizedBox(height: 18),

                      // DESCRIPTION
                      _label('DESCRIPTION', isDark),

                      const SizedBox(height: 8),

                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: _inputDecoration(
                          isDark,
                          hint: 'Optional notes...',
                        ),
                      ),

                      const SizedBox(height: 18),

                      // CATEGORY
                      _label('CATEGORY', isDark),

                      const SizedBox(height: 8),

                      _buildCategoryDropdown(isDark),

                      const SizedBox(height: 18),

                      // FREQUENCY
                      _label('FREQUENCY', isDark),

                      const SizedBox(height: 8),

                      _buildFrequencyDropdown(isDark),

                      const SizedBox(height: 18),

                      // CUSTOM COLOR & EMOJI
                      _label('CUSTOMIZE', isDark),

                      const SizedBox(height: 8),

                      // Color and Emoji Preview
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
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
                            // Color Picker Button
                            GestureDetector(
                              onTap: () => _showColorPicker(isDark),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _customColor,
                                      border: Border.all(
                                        color: _customColor.withOpacity(0.5),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: _customColor.withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.palette_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Color',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Emoji Picker Button
                            GestureDetector(
                              onTap: () => _showEmojiPicker(isDark),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _customColor.withOpacity(0.15),
                                      border: Border.all(
                                        color: _customColor.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _customEmoji,
                                        style: const TextStyle(fontSize: 28),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Emoji',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white54
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Preview
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _customColor.withOpacity(0.15),
                                    border: Border.all(
                                      color: _customColor.withOpacity(0.3),
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _customEmoji,
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Preview',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white54
                                        : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // DATES
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              isDark,
                              'START',
                              _startDate,
                              (d) {
                                if (d != null) {
                                  setState(
                                    () => _startDate = d,
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildDateField(
                              isDark,
                              'END',
                              _endDate,
                              (d) {
                                setState(
                                  () => _endDate = d,
                                );
                              },
                              isOptional: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // CREATE / SAVE BUTTON
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
                                borderRadius: BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            child: Text(
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

  // ── Category dropdown ───────────────────────────────────────────────────────
  Widget _buildCategoryDropdown(bool isDark) {
    return Consumer(
      builder: (context, ref, _) {
        final categoriesAsync = ref.watch(categoriesProvider);
        return categoriesAsync.when(
          loading: () => const SizedBox(
            height: 44,
            child: Center(
                child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 1.5))),
          ),
          error: (_, __) => Text('Failed to load categories',
              style: TextStyle(color: AppColors.error, fontSize: 13)),
          data: (categories) {
            // Find selected category to show its color in the field
            HabitCategory? selectedCategory;
            if (_selectedCategoryId != null) {
              try {
                selectedCategory = categories
                    .firstWhere((cat) => cat.id == _selectedCategoryId);
              } catch (_) {
                selectedCategory = null;
              }
            }

            Color selectedColor = AppColors.primaryPurple;
            if (selectedCategory != null &&
                selectedCategory.colorHex.isNotEmpty) {
              try {
                selectedColor = Color(
                  int.parse(selectedCategory.colorHex.replaceFirst('#', ''),
                          radix: 16) +
                      0xFF000000,
                );
              } catch (e) {
                selectedColor = AppColors.primaryPurple;
              }
            }

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                isExpanded: true,
                itemHeight: 60,
                icon: Icon(Icons.expand_more,
                    size: 18, color: isDark ? Colors.white38 : Colors.black38),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.03),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  prefix: selectedCategory != null
                      ? Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: selectedColor.withOpacity(0.15),
                                  border: Border.all(
                                      color: selectedColor.withOpacity(0.3),
                                      width: 1),
                                ),
                                child: Center(
                                  child: Text(selectedCategory.icon,
                                      style: const TextStyle(fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                dropdownColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
                style: TextStyle(
                    fontSize: 14, color: isDark ? Colors.white : Colors.black),
                hint: Text('Select category',
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white30 : Colors.black26)),
                items: categories.map((cat) {
                  Color catColor = AppColors.primaryPurple;
                  try {
                    catColor = Color(int.parse(
                            cat.colorHex.replaceFirst('#', ''),
                            radix: 16) +
                        0xFF000000);
                  } catch (e) {
                    catColor = AppColors.primaryPurple;
                  }

                  return DropdownMenuItem<String>(
                    value: cat.id,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: catColor.withOpacity(0.08),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: catColor.withOpacity(0.2),
                              border: Border.all(
                                  color: catColor.withOpacity(0.4), width: 1),
                            ),
                            child: Center(
                              child: Text(cat.icon,
                                  style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isDark ? Colors.white : Colors.black87,
                                  ),
                                ),
                                Text(
                                  cat.description,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.white30
                                        : Colors.black38,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedCategoryId = value),
              ),
            );
          },
        );
      },
    );
  }

// ── Frequency dropdown ──────────────────────────────────────────────────────
  Widget _buildFrequencyDropdown(bool isDark) {
    String _getFrequencyEmoji(String freq) {
      switch (freq.toLowerCase()) {
        case 'daily':
          return '📅';
        case 'weekly':
          return '📆';
        case 'monthly':
          return '📊';
        default:
          return '⏰';
      }
    }

    return MenuAnchor(
      builder: (
        BuildContext context,
        MenuController controller,
        Widget? child,
      ) {
        return GestureDetector(
          onTap: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
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
              children: [
                Text(
                  _getFrequencyEmoji(_selectedFrequency),
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _selectedFrequency.capitalize(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ],
            ),
          ),
        );
      },
      menuChildren: _frequencies.map((freq) {
        final emoji = _getFrequencyEmoji(freq);
        return MenuItemButton(
          style: MenuItemButton.styleFrom(
            minimumSize: const Size(
              160,
              48,
            ),
          ),
          onPressed: () {
            setState(() {
              _selectedFrequency = freq;
            });
          },
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                freq.capitalize(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Date field ──────────────────────────────────────────────────────────────
  Widget _buildDateField(
    bool isDark,
    String label,
    DateTime? date,
    Function(DateTime?) onChanged, {
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label, isDark),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: isDark ? Colors.white12 : Colors.black12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 14, color: AppColors.primaryPurple.withOpacity(0.7)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select',
                    style: TextStyle(
                      fontSize: 13,
                      color: date != null
                          ? (isDark ? Colors.white : Colors.black)
                          : (isDark ? Colors.white30 : Colors.black26),
                    ),
                  ),
                ),
                if (isOptional && date != null)
                  GestureDetector(
                    onTap: () => onChanged(null),
                    child: Icon(Icons.close,
                        size: 14,
                        color: isDark ? Colors.white38 : Colors.black38),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Submit ──────────────────────────────────────────────────────────────────
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
      });
      Navigator.pop(context);
      return;
    }

    if (_selectedCategoryId == null) {
      _showSnack('Please select a category');
      return;
    }

    try {
      await ref.read(habitsProvider.notifier).createHabit(
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
          );
      if (mounted) {
        Navigator.pop(context);
        _showSnack('Habit created');
      }
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  // ── Color Picker ────────────────────────────────────────────────────────────
  void _showColorPicker(bool isDark) {
    final colors = [
      AppColors.primaryPurple,
      AppColors.accentRed,
      AppColors.accentOrange,
      AppColors.accentYellow,
      AppColors.secondaryGreen,
      AppColors.secondaryGreenLight,
      AppColors.accentBlue,
      AppColors.accentOrange,
      const Color(0xFFEC4899), // Pink
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFF06B6D4), // Cyan
      const Color(0xFF6366F1), // Indigo
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Color',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: colors.length,
              itemBuilder: (context, index) {
                final color = colors[index];
                final isSelected = color.value == _customColor.value;

                return GestureDetector(
                  onTap: () {
                    setState(() => _customColor = color);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: isSelected
                          ? Border.all(
                              color: Colors.white,
                              width: 3,
                            )
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withOpacity(0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Emoji Picker ────────────────────────────────────────────────────────────
  void _showEmojiPicker(bool isDark) {
    final emojis = [
      '✨',
      '⭐',
      '🌟',
      '💫',
      '🔥',
      '⚡',
      '💎',
      '🎯',
      '🏆',
      '🎉',
      '🎊',
      '🎈',
      '💪',
      '🚀',
      '🌈',
      '🎨',
      '💚',
      '❤️',
      '💙',
      '💛',
      '🧡',
      '🤍',
      '🖤',
      '💜',
      '😊',
      '😍',
      '🤔',
      '😎',
      '🥳',
      '🚀',
      '👑',
      '🎁',
      '📚',
      '🎓',
      '🏃',
      '🧘',
      '🏋️',
      '🤸',
      '⛹️',
      '🚴',
      '🎵',
      '🎶',
      '🎤',
      '🎧',
      '🎮',
      '🎲',
      '🃏',
      '🎭',
      '🍎',
      '🍊',
      '🍋',
      '🍌',
      '🍉',
      '🥗',
      '🍱',
      '☕',
      '🌺',
      '🌸',
      '🌼',
      '🌻',
      '🌷',
      '🌹',
      '🥀',
      '🎀',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Emoji',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: emojis.length,
              itemBuilder: (context, index) {
                final emoji = emojis[index];
                final isSelected = emoji == _customEmoji;

                return GestureDetector(
                  onTap: () {
                    setState(() => _customEmoji = emoji);
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected
                          ? _customColor.withOpacity(0.2)
                          : (isDark
                              ? Colors.white.withOpacity(0.04)
                              : Colors.black.withOpacity(0.03)),
                      border: Border.all(
                        color: isSelected
                            ? _customColor
                            : (isDark ? Colors.white12 : Colors.black12),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Extensions / helpers ──────────────────────────────────────────────────────
extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}

DateTime _dateOnly(DateTime date) {
  final d = date.toLocal();
  return DateTime(d.year, d.month, d.day);
}
