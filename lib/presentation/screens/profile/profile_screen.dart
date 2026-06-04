import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/providers/profile_provider.dart';
import 'followers_screen.dart';
import 'following_screen.dart';

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: profileState.isLoading && profile == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  if (profile != null) ...[
                    _buildProfileHeader(
                      profile,
                      isDark,
                      profileState.avatarVersion,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Column(
                        children: [
                          _buildFollowStats(isDark),
                          const SizedBox(height: 16),
                          _buildQuickActions(isDark),
                        ],
                      ),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: _buildErrorWidget(isDark),
                    ),
                ],
              ),
            ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PROFILE HEADER with gradient banner
  // ─────────────────────────────────────────────────────────────

  Widget _buildProfileHeader(
    dynamic profile,
    bool isDark,
    int avatarVersion,
  ) {
    final username = profile.username as String? ?? '';
    final bio = profile.bio as String?;
    final avatarUrl = profile.avatarUrl as String?;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // Gradient banner
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark ? AppColors.heroGradientDark : AppColors.heroGradient,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: widget.onNavigateToSettings ?? () {},
                  ),
                ],
              ),
            ),
          ),
        ),
        // Card overlapping the banner
        Positioned(
          top: 130,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black26 : AppColors.shadowLight,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  username,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                if (bio != null && bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        // Avatar floating between banner and card
        Positioned(
          top: 90,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryPurple.withOpacity(0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                _buildAvatarWidget(
                  avatarUrl: avatarUrl,
                  username: username,
                  size: 80,
                  cacheKey: avatarVersion,
                ),
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                      width: 2.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Spacer to push content below the overlapping card
        SizedBox(
          height: bio != null && bio.isNotEmpty ? 290 : 260,
          width: double.infinity,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // AVATAR
  // ─────────────────────────────────────────────────────────────

  Widget _buildAvatarWidget({
    required String? avatarUrl,
    required String username,
    required double size,
    int cacheKey = 0,
  }) {
    final trimmed = avatarUrl?.trim() ?? '';

    if (trimmed.isNotEmpty) {
      final bustedUrl = cacheKey > 0 ? '$trimmed?v=$cacheKey' : trimmed;

      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: bustedUrl,
          cacheKey: bustedUrl,
          fit: BoxFit.cover,
          width: size,
          height: size,
          placeholder: (_, __) {
            return Shimmer.fromColors(
              baseColor: AppColors.shimmerBaseLight,
              highlightColor: AppColors.shimmerHighlightLight,
              child: Container(
                width: size,
                height: size,
                color: AppColors.shimmerBaseLight,
              ),
            );
          },
          errorWidget: (_, __, ___) {
            return _buildInitialsAvatar(
              username,
              size,
            );
          },
        ),
      );
    }

    return _buildInitialsAvatar(username, size);
  }

  Widget _buildInitialsAvatar(
    String username,
    double size,
  ) {
    final initial = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.heroGradient,
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: size * 0.38,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FOLLOW STATS
  // ─────────────────────────────────────────────────────────────

  Widget _buildFollowStats(bool isDark) {
    final followersState = ref.watch(followersProvider);
    final followingState = ref.watch(followingProvider);

    return Row(
      children: [
        Expanded(
          child: _buildFollowStatCard(
            isDark: isDark,
            label: 'Followers',
            count: followersState.meta.total,
            icon: Icons.people_outline_rounded,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FollowersScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFollowStatCard(
            isDark: isDark,
            label: 'Following',
            count: followingState.meta.total,
            icon: Icons.person_add_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FollowingScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFollowStatCard({
    required bool isDark,
    required String label,
    required int count,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black12 : AppColors.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.12),
                    AppColors.primaryPurple.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              count.toString(),
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // QUICK ACTIONS
  // ─────────────────────────────────────────────────────────────

  Widget _buildQuickActions(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black12 : AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildQuickActionItem(
            icon: Icons.refresh_rounded,
            title: 'Refresh Profile',
            isDark: isDark,
            onTap: () {
              ref.read(profileProvider.notifier).fetchUserProfile();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          _buildQuickActionItem(
            icon: Icons.settings_outlined,
            title: 'Settings',
            isDark: isDark,
            onTap: widget.onNavigateToSettings ?? () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPurple.withOpacity(0.12),
                    AppColors.primaryPurple.withOpacity(0.06),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: AppColors.primaryPurple,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // ERROR
  // ─────────────────────────────────────────────────────────────

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
