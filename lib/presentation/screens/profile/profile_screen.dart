import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNavigateToSettings;

  const ProfileScreen({
    Key? key,
    this.onNavigateToSettings,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

return Scaffold(
  appBar: AppBar(
    title: const Text('Profile'),
    backgroundColor: Colors.white,
    elevation: 0,
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 12),
        child: _glassIconButton(
          icon: Icons.settings_outlined,
          isDark: isDark,
          size: 60,
          onTap: widget.onNavigateToSettings ?? () {},
        ),
      ),
    ],
  ),
      
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        child: Column(
          children: [
            const SizedBox(height: 100),
            _buildProfileHeader(isDark),
            const SizedBox(height: 20),
            _buildStatsRow(isDark),
            const SizedBox(height: 24),
            _buildSectionTitle('Achievements', isDark),
            const SizedBox(height: 12),
            _buildAchievements(isDark),
            const SizedBox(height: 24),
            _buildSectionTitle('Recent Activity', isDark),
            const SizedBox(height: 12),
            _buildRecentActivity(isDark),
          ],
        ),
      ),
    );
  }

  // ── Glass Icon Button ────────────────────────────────────────────────────

  Widget _glassIconButton({
    required IconData icon,
    required bool isDark,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.10),
                        Colors.white.withOpacity(0.05),
                      ]
                    : [
                        Colors.white.withOpacity(0.60),
                        Colors.white.withOpacity(0.35),
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.18),
                width: 0.5,
              ),
            ),
            child: Icon(
              icon,
              size: 24,
              color: isDark
                  ? Colors.white.withOpacity(0.75)
                  : Colors.black.withOpacity(0.55),
            ),
          ),
        ),
      ),
    );
  }

  // ── Profile Header ───────────────────────────────────────────────────────

  Widget _buildProfileHeader(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryPurple.withOpacity(0.30),
                AppColors.primaryPurpleDark.withOpacity(0.16),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withOpacity(0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.20),
                blurRadius: 30,
                spreadRadius: 1,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryPurple,
                          AppColors.primaryPurpleDark,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.30),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryPurple.withOpacity(0.40),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'J',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22c55e),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'John Doe',
                style: AppTypography.titleLarge(Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                '@johndoe',
                style: AppTypography.bodySmall(
                  Colors.white.withOpacity(0.65),
                ),
              ),
              const SizedBox(height: 16),
              _glassChip('🗓 Joined Jan 2024'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassChip(String text) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.18),
                AppColors.primaryPurple.withOpacity(0.12),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.20),
              width: 0.5,
            ),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  // ── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow(bool isDark) {
    return Row(
      children: [
        _buildStatCard('12', 'Streak', '🔥', isDark),
        const SizedBox(width: 10),
        _buildStatCard('45', 'Habits', '📝', isDark),
        const SizedBox(width: 10),
        _buildStatCard('8', 'Badges', '🏅', isDark),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    String icon,
    bool isDark,
  ) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.03),
                      ]
                    : [
                        Colors.white.withOpacity(0.65),
                        AppColors.primaryPurple.withOpacity(0.06),
                      ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.14),
                width: 0.5,
              ),
            ),
            child: Column(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withOpacity(0.50)
                        : Colors.black.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Section Title ────────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title, bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: AppTypography.titleLarge(
          isDark ? AppColors.darkText : AppColors.lightText,
        ),
      ),
    );
  }

  // ── Achievements ─────────────────────────────────────────────────────────

  Widget _buildAchievements(bool isDark) {
    final badges = [
      ('🏆', 'Week Master'),
      ('🔥', '30 Day Streak'),
      ('⭐', 'Perfect Week'),
      ('🎯', 'Goal Getter'),
      ('💪', 'Consistency'),
      ('🧘', 'Zen Mode'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: badges.map((b) => _buildBadge(b.$1, b.$2, isDark)).toList(),
    );
  }

  Widget _buildBadge(String icon, String label, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.04),
                    ]
                  : [
                      Colors.white.withOpacity(0.65),
                      AppColors.primaryPurple.withOpacity(0.08),
                    ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : AppColors.primaryPurple.withOpacity(0.18),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withOpacity(0.80)
                      : Colors.black.withOpacity(0.70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Recent Activity ──────────────────────────────────────────────────────

  Widget _buildRecentActivity(bool isDark) {
    final activities = [
      ('🏃', 'Morning Run', 'Completed', '2h ago', true),
      ('📖', 'Read 30 Pages', 'Completed', 'Yesterday', true),
      ('🧘', 'Meditate', 'Skipped', '2 days ago', false),
      ('💧', 'Drink Water', 'Completed', '2 days ago', true),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withOpacity(0.07),
                      Colors.white.withOpacity(0.03),
                    ]
                  : [
                      Colors.white.withOpacity(0.65),
                      AppColors.primaryPurple.withOpacity(0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.14),
              width: 0.5,
            ),
          ),
          child: Column(
            children: activities.asMap().entries.map((entry) {
              final i = entry.key;
              final a = entry.value;
              return Column(
                children: [
                  _buildActivityRow(
                    icon: a.$1,
                    title: a.$2,
                    status: a.$3,
                    time: a.$4,
                    completed: a.$5,
                    isDark: isDark,
                  ),
                  if (i < activities.length - 1)
                    Divider(
                      height: 1,
                      thickness: 0.5,
                      color: isDark
                          ? Colors.white.withOpacity(0.06)
                          : Colors.black.withOpacity(0.05),
                      indent: 56,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityRow({
    required String icon,
    required String title,
    required String status,
    required String time,
    required bool completed,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : Colors.black.withOpacity(0.06),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? Colors.white.withOpacity(0.40)
                        : Colors.black.withOpacity(0.35),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: completed
                  ? const Color(0xFF22c55e).withOpacity(0.15)
                  : Colors.orange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: completed
                    ? const Color(0xFF22c55e).withOpacity(0.30)
                    : Colors.orange.withOpacity(0.25),
                width: 0.5,
              ),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: completed
                    ? const Color(0xFF16a34a)
                    : Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}