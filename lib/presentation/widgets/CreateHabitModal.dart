import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../widgets/custom_buttons.dart';

class CreateHabitModal extends StatefulWidget {
  final VoidCallback onClose;

  const CreateHabitModal({
    Key? key,
    required this.onClose,
  }) : super(key: key);

  @override
  State<CreateHabitModal> createState() => _CreateHabitModalState();
}

class _CreateHabitModalState extends State<CreateHabitModal> {
  final _habitTitleController = TextEditingController();

  String _selectedCategory = 'Fitness';
  String _selectedFrequency = 'Daily';

  @override
  void dispose() {
    _habitTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Create New Habit',
                      style: AppTypography.headlineLarge(
                        isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: widget.onClose,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildTextField(isDark),
                const SizedBox(height: 16),
                _buildCategorySelector(isDark),
                const SizedBox(height: 16),
                _buildFrequencySelector(isDark),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Cancel',
                        onPressed: widget.onClose,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Create Habit',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Habit Title',
          style: AppTypography.labelLarge(
            isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: _habitTitleController,
          decoration: InputDecoration(
            hintText: 'e.g., Morning Run',
            prefixIcon: const Icon(Icons.label_outlined),
            filled: true,
            fillColor:
                isDark ? AppColors.darkBackground : AppColors.lightBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return const SizedBox();
  }

  Widget _buildFrequencySelector(bool isDark) {
    return const SizedBox();
  }
}


