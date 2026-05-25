import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/habit_model.dart';
import '../../../data/providers/habit_provider.dart';
import '../../../data/providers/category_providers.dart';
import './custom_buttons.dart';

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
  InputDecoration _inputDecoration(bool isDark, {String? hint, Widget? suffix}) {
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
      fillColor: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
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
  final bg = isDark
      ? AppColors.darkSurface
      : AppColors.lightSurface;

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
                color: isDark
                    ? Colors.white24
                    : Colors.black12,
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
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.editingHabit != null
                        ? 'Edit Habit'
                        : 'New Habit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? Colors.white
                          : Colors.black,
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
                        color: isDark
                            ? Colors.white70
                            : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Divider(
              height: 1,
              color: isDark
                  ? Colors.white10
                  : Colors.black.withOpacity(0.05),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // TITLE
                    _label('TITLE', isDark),

                    const SizedBox(height: 8),

                    TextField(
                      controller: _titleController,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.white
                            : Colors.black,
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
                        color: isDark
                            ? Colors.white
                            : Colors.black,
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
                          backgroundColor:
                              AppColors.primaryPurple,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(14),
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
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                12,
                              ),
                            ),
                          ),
                          child: Text(
                            'Delete Habit',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.error,
                              fontWeight:
                                  FontWeight.w600,
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
            child: Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 1.5))),
          ),
          error: (_, __) => Text('Failed to load categories',
              style: TextStyle(color: AppColors.error, fontSize: 13)),
          data: (categories) {
            return DropdownButtonFormField(
              value: _selectedCategoryId,
              isExpanded: true,
               itemHeight: 148,
              icon: Icon(Icons.expand_more, size: 18, color: isDark ? Colors.white38 : Colors.black38),
              decoration: _inputDecoration(isDark),
              dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white : Colors.black),
              hint: Text('Select category',
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.white30 : Colors.black26)),
              items: categories.map((cat) {
                return DropdownMenuItem(
                  value: cat.id,
                  child: Row(
                    children: [
                      Text(cat.icon, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 10),
                      Text(cat.name, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategoryId = value),
            );
          },
        );
      },
    );
  }

// ── Frequency dropdown ──────────────────────────────────────────────────────
Widget _buildFrequencyDropdown(bool isDark) {
  return MenuAnchor(
    builder: (
      BuildContext context,
      MenuController controller,
      Widget? child,
    ) {
      return GestureDetector(
        onTap: () {
          controller.isOpen
              ? controller.close()
              : controller.open();
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

            borderRadius:
                BorderRadius.circular(8),

            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.black12,
            ),
          ),

          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedFrequency.capitalize(),

                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),

              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: isDark
                    ? Colors.white38
                    : Colors.black38,
              ),
            ],
          ),
        ),
      );
    },

    menuChildren: _frequencies.map((freq) {
      return MenuItemButton(
        style: MenuItemButton.styleFrom(
          minimumSize: const Size(
            160,
            42,
          ),
        ),

        onPressed: () {
          setState(() {
            _selectedFrequency = freq;
          });
        },

        child: Text(
          freq.capitalize(),
          style: const TextStyle(
            fontSize: 14,
          ),
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
              color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
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
                    child: Icon(Icons.close, size: 14,
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
}

// ── Extensions / helpers ──────────────────────────────────────────────────────
extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
}

DateTime _dateOnly(DateTime date) {
  final d = date.toLocal();
  return DateTime(d.year, d.month, d.day);
}