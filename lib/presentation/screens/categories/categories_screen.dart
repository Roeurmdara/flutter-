import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/custom_inputs.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final categories = [
    {'name': 'Fitness', 'icon': '💪', 'count': 3, 'color': '#FF6B6B'},
    {'name': 'Study', 'icon': '📚', 'count': 2, 'color': '#A8E6CF'},
    {'name': 'Health', 'icon': '🏥', 'count': 4, 'color': '#4ECDC4'},
    {'name': 'Productivity', 'icon': '⚡', 'count': 2, 'color': '#FFB84D'},
    {'name': 'Lifestyle', 'icon': '🌟', 'count': 3, 'color': '#A8D8EA'},
    {'name': 'Mindset', 'icon': '🧠', 'count': 2, 'color': '#C8B8FF'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return _buildCategoryCard(
            icon: category['icon'] as String,
            name: category['name'] as String,
            count: category['count'] as int,
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard({
    required String icon,
    required String name,
    required int count,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              name,
              style: AppTypography.titleMedium(
                isDark ? AppColors.darkText : AppColors.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$count habits',
              style: AppTypography.bodySmall(
                isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
