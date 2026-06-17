
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:habit_tracker/core/theme/app_typography.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/providers/profile_provider.dart';
import '../../../data/providers/habit_provider.dart';
import 'followers_screen.dart';
import 'following_screen.dart';
import 'edit_profile_form.dart';
import 'widgets/profile_stats_card.dart';
import 'widgets/profile_action_buttons.dart';


class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToSettings;

  const ProfileScreen({
    super.key,
    this.onNavigateToSettings,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(profileProvider.notifier).fetchUserProfile();
        ref.read(followersProvider.notifier).fetchFollowers();
        ref.read(followingProvider.notifier).fetchFollowing();
        ref.read(habitsProvider.notifier).loadHabits();
      }
    });
  }

  void _openEditProfileSheet(dynamic profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: EditProfileForm(
              profile: profile,
              profileProvider: profileProvider,
              onCancel: () => Navigator.pop(context),
              onSaveSuccess: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully'),
                  ),
                );
                ref.read(profileProvider.notifier).fetchUserProfile();
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    final followersState = ref.watch(followersProvider);
    final followingState = ref.watch(followingProvider);
    final habitState = ref.watch(habitsProvider);

    return Scaffold(
  backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
  appBar: AppBar(
    backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    elevation: 0,
    scrolledUnderElevation: 0,
    title: Text(
      'Profile',
      style:AppTypography.titleLarge(
        isDark ? AppColors.darkText : AppColors.lightText,
      ).copyWith(
        fontSize: 18,
      ),
    ),
    actions: [
      IconButton(
        icon: Icon(
          Icons.settings_outlined,
          color: isDark ? AppColors.darkText : AppColors.lightText,
          size: 24, // Matched with standard action bar size
        ),
        onPressed: widget.onNavigateToSettings ?? () {},
      ),
    ],
  ),
  body: SafeArea(
    child: profileState.isLoading && profile == null
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : profile != null
            ? SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Avatar Card Stack
                      ProfileStatsCard(
                        username: profile.username as String? ?? '',
                        bio: profile.bio,
                        avatarUrl: profile.avatarUrl,
                        avatarVersion: profileState.avatarVersion,
                        followersCount: followersState.meta.total,
                        followingCount: followingState.meta.total,
                        postsCount: habitState.habits.length,
                        onFollowersTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FollowersScreen(),
                            ),
                          );
                        },
                        onFollowingTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const FollowingScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // 2. Action Buttons Row
                      ProfileActionButtons(
                        onEditProfileTap: () => _openEditProfileSheet(profile),
                      ),
                    ],
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(24),
                child: _buildErrorWidget(isDark),
              ),
  ),
);
  }

  Widget _buildErrorWidget(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: 12),
          Text(
            'Unable to load profile',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please ensure you are logged in and have a valid token.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
