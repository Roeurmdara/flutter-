import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/custom_buttons.dart';
import '../../widgets/custom_inputs.dart';
import 'dart:ui';


class HomeDashboardScreen extends StatefulWidget {
  final Function(bool isDark) onThemeToggle;
  final bool isDarkMode;

  const HomeDashboardScreen({
    Key? key,
    required this.onThemeToggle,
    required this.isDarkMode,
  }) : super(key: key);

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
  appBar: AppBar(
    title: Image.asset(
      'assets/images/meeeee.png',
      height: 50,
    ),
    centerTitle: false,
    actions: [
      IconButton(
        onPressed: () {},
        icon: const Icon(Icons.notifications_outlined),
      ),
    ],
  ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting Card
              _buildGreetingCard(isDark),
              const SizedBox(height: 24),

              // Stats Row
              _buildStatsRow(isDark),
              const SizedBox(height: 24),

              // Today's Habits Section
              _buildSectionTitle('Today\'s Habits', isDark),
              const SizedBox(height: 12),
              _buildTodaysHabits(isDark),
              const SizedBox(height: 24),

              // Weekly Progress
              _buildSectionTitle('Weekly Progress', isDark),
              const SizedBox(height: 12),
              _buildWeeklyChart(isDark),
              const SizedBox(height: 24),

              // Recommendations
              _buildSectionTitle('Recommendations', isDark),
              const SizedBox(height: 12),
              _buildRecommendations(isDark),
            ],
          ),
        ),
      ),
    );
  }
Widget _buildGreetingCard(bool isDark) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryPurple.withOpacity(0.35),
              AppColors.primaryPurpleDark.withOpacity(0.18),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.18),
            width: 1.2,
          ),
        
        ),
        child: Stack(
          children: [
            // ── top glossy specular reflection ──
            Positioned(
              top: -30,
              left: -20,
              child: Container(
                width: 180,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.18),
                    
                    ],
                  ),
                ),
              ),
            ),

            // ── bottom-right inner glow ──
  

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning, User! ',
                  style: AppTypography.headlineMedium(Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'Keep your streaks alive today',
                  style: AppTypography.bodyMedium(
                    Colors.white.withOpacity(0.82),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _glassChip('🔥 7 Day Streak', AppColors.primaryPurple),
                    const SizedBox(width: 10),
                    _glassChip('✅ 5 Done Today', AppColors.primaryPurpleDark),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _glassChip(String text, Color color) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(30),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.18),
              color.withOpacity(0.22),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.20),
            width: 1.0,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}


  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        _buildStatCard(
          title: 'Current Streak',
          value: '12',
          icon: '🔥',
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'Total Habits',
          value: '8',
          icon: '📝',
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          title: 'This Month',
          value: '85%',
          icon: '📊',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String icon,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTypography.titleLarge(
                isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTypography.bodySmall(
                isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTypography.titleLarge(
            isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        CustomTextButton(
          label: 'View All',
          onPressed: () {},
          style: AppTypography.labelSmall(AppColors.primaryPurple),
        ),
      ],
    );
  }

  Widget _buildTodaysHabits(bool isDark) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: HabitProgressCard(
            title: ['Morning Run', 'Read 30 Pages', 'Meditate'][index],
            icon: ['🏃', '📖', '🧘'][index],
            progress: [75, 50, 100][index],
            streak: [12, 8, 5][index],
            isCompletedToday: index == 2,
            onTap: () {},
            onPress: () {},
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(bool isDark) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final values = [4, 6, 5, 7, 8, 6, 3];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              7,
              (index) => Column(
                children: [
                  Text(
                    days[index],
                    style: AppTypography.labelSmall(
                      isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 30,
                    height: values[index] * 3.0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(
                        values[index] / 8,
                      ),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations(bool isDark) {
    return Column(
      children: [
        _buildRecommendationCard(
          icon: '💡',
          title: 'Try Yoga',
          description: 'Flexible and stress-relieving',
          isDark: isDark,
        ),
        const SizedBox(height: 12),
        _buildRecommendationCard(
          icon: '🧠',
          title: 'Morning Journaling',
          description: 'Reflect and plan your day',
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required String icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleSmall(
                    isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                Text(
                  description,
                  style: AppTypography.bodySmall(
                    isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.add_circle_outline,
            color: AppColors.primaryPurple,
          ),
        ],
      ),
    );
  }
}
