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

  const CreateHabitModal({
    Key? key,
    this.editingHabit,
    this.onSubmit,
  }) : super(key: key);

  @override
  ConsumerState<CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends ConsumerState<CreateHabitModal> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;

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
    _categoryController =
        TextEditingController(text: widget.editingHabit?.category ?? 'Health');
    _selectedFrequency = widget.editingHabit?.frequency ?? 'daily';
    _startDate = widget.editingHabit?.startDate ?? DateTime.now();
    _endDate = widget.editingHabit?.endDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.editingHabit != null
                          ? 'Edit Habit'
                          : 'Create New Habit',
                      style: AppTypography.headlineLarge(
                        isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Title Input
                _buildTextInput(
                  isDark,
                  'Habit Title',
                  _titleController,
                  'e.g., Morning Run',
                  Icons.label_outlined,
                ),
                const SizedBox(height: 16),

                // Description Input
                _buildTextInput(
                  isDark,
                  'Description',
                  _descriptionController,
                  'Add details about your habit',
                  Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 16),

                // Category Selector
                _buildCategorySelector(isDark),
                const SizedBox(height: 16),

                // Frequency Selector
                _buildFrequencySelector(isDark),
                const SizedBox(height: 16),

                // Date Selectors
                _buildDateSelector(isDark, 'Start Date', _startDate, (date) {
                  if (date != null)
                    setState(() => _startDate = date); // ← guard null
                }),
                const SizedBox(height: 12),

                _buildDateSelector(isDark, 'End Date (Optional)', _endDate,
                    (date) {
                  setState(() => _endDate =
                      date); // ← _endDate is DateTime?, so null is fine
                }, isOptional: true),
                const SizedBox(height: 32),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label:
                            widget.editingHabit != null ? 'Update' : 'Create',
                        onPressed: () async {
                          if (_titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please enter habit title')),
                            );
                            return;
                          }

                          if (widget.editingHabit != null &&
                              widget.onSubmit != null) {
                            // Edit mode - call onSubmit
                            widget.onSubmit!({
                              'title': _titleController.text,
                              'description': _descriptionController.text,
                              'frequencyType': _selectedFrequency,
                              'frequencyConfig': [_selectedFrequency],
                            });
                          } else {
                            // Create mode - use provider
                            if (_selectedCategoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please select a category')),
                              );
                              return;
                            }

                            try {
                              await ref
                                  .read(habitsProvider.notifier)
                                  .createHabit(
                                    categoryId: _selectedCategoryId!,
                                    title: _titleController.text,
                                    description: _descriptionController.text,
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
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Habit created successfully!')),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            }
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInput(
    bool isDark,
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge(
            isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          minLines: maxLines == 1 ? 1 : null,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: maxLines == 1 ? Icon(icon) : null,
            filled: true,
            fillColor: isDark ? AppColors.darkBackground : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(categoriesProvider);

        return categoriesAsync.when(
          loading: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: AppTypography.labelLarge(
                  isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const CircularProgressIndicator(),
            ],
          ),
          error: (error, stack) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Category',
                style: AppTypography.labelLarge(
                  isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error loading categories',
                style: AppTypography.bodySmall(Colors.red),
              ),
            ],
          ),
          data: (categories) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: AppTypography.labelLarge(
                    isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: categories
                      .map((category) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategoryId = category.id;
                                _categoryController.text = category.name;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedCategoryId == category.id
                                    ? AppColors.primaryPurple
                                    : (isDark
                                        ? AppColors.darkBackground
                                        : Colors.grey[100]),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _selectedCategoryId == category.id
                                      ? AppColors.primaryPurple
                                      : (isDark
                                          ? AppColors.darkBorder
                                          : AppColors.lightBorder),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    category.icon,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category.name,
                                    style: AppTypography.bodySmall(
                                      _selectedCategoryId == category.id
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ))
                      .toList(),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFrequencySelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency',
          style: AppTypography.labelLarge(
            isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _frequencies
              .map((freq) => Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedFrequency = freq);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedFrequency == freq
                              ? AppColors.primaryPurple
                              : (isDark
                                  ? AppColors.darkBackground
                                  : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _selectedFrequency == freq
                                ? AppColors.primaryPurple
                                : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          freq.capitalize(),
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall(
                            _selectedFrequency == freq
                                ? Colors.white
                                : (isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDateSelector(
    bool isDark,
    String label,
    DateTime? date,
    Function(DateTime?) onDateChanged, {
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelLarge(
            isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              onDateChanged(picked);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryPurple,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  date != null
                      ? '${date.day}/${date.month}/${date.year}'
                      : 'Select date',
                  style: AppTypography.bodySmall(
                    isDark ? Colors.white : Colors.black,
                  ),
                ),
                if (isOptional && date != null) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => onDateChanged(null),
                    child: Icon(
                      Icons.close,
                      color: isDark ? Colors.white70 : Colors.black54,
                      size: 18,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
