import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final communities = [
    {
      'name': 'Fitness Enthusiasts',
      'members': 1240,
      'icon': '💪',
      'joined': true
    },
    {'name': 'Study Motivation', 'members': 890, 'icon': '📚', 'joined': false},
    {
      'name': 'Healthy Lifestyle',
      'members': 2150,
      'icon': '🌟',
      'joined': true
    },
    {'name': 'Morning Runners', 'members': 450, 'icon': '🏃', 'joined': false},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: communities.length,
        itemBuilder: (context, index) {
          final community = communities[index];
          return _buildCommunityCard(
            icon: community['icon'] as String,
            name: community['name'] as String,
            members: community['members'] as int,
            isJoined: community['joined'] as bool,
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildCommunityCard({
    required String icon,
    required String name,
    required int members,
    required bool isJoined,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleMedium(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$members members',
                  style: AppTypography.bodySmall(
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: isJoined
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.primaryPurple,
            ),
            child: Text(
              isJoined ? 'Joined' : 'Join',
              style: TextStyle(
                color: isJoined ? AppColors.success : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
